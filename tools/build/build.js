#!/usr/bin/env node
/**
 * Build script for /tg/station 13 codebase.
 *
 * This script uses Juke Build, read the docs here:
 * https://github.com/stylemistake/juke-build
 *
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import fs from 'fs';
import { DreamDaemon, DreamMaker } from './lib/byond.js';
import { yarn } from './lib/yarn.js';
import Juke from './juke/index.js';

Juke.chdir('../..', import.meta.url);
Juke.setup({ file: import.meta.url }).then((code) => process.exit(code));

const DME_NAME = 'baystation12';

export const DefineParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'D',
});

export const MapOverrideParameter = new Juke.Parameter({
  type: 'string',
  alias: 'M',
})

export const PortParameter = new Juke.Parameter({
  type: 'string',
  alias: 'p',
});

export const CiParameter = new Juke.Parameter({
  type: 'boolean',
});

export const DmMapsIncludeTarget = new Juke.Target({
  executes: async () => {
    const folders = [
      ...Juke.glob('maps/away/**/*.dmm'),
      ...Juke.glob('maps/random_ruins/**/*.dmm'),
      ...Juke.glob('maps/RandomZLevels/**/*.dmm'),
      ...Juke.glob('maps/shipmaps/**/*.dmm'),
      ...Juke.glob('maps/templates/**/*.dmm'),
    ];
    const content = folders
      .map((file) => file.replace('maps/', ''))
      .map((file) => `#include "${file}"`)
      .join('\n') + '\n';
    fs.writeFileSync('maps/templates.dm', content);
  },
});

export const DmTarget = new Juke.Target({
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_MAPS') && DmMapsIncludeTarget,
  ],
  inputs: [
    'Haven/**',
    'maps/**',
    'code/**',
    'html/**',
    'icons/**',
    `${DME_NAME}.dme`,
  ],
  outputs: [
    `${DME_NAME}.dmb`,
    `${DME_NAME}.rsc`,
  ],
  parameters: [DefineParameter],
  executes: async ({ get }) => {
    const includes = [];
    const defines = get(DefineParameter);
    const map_override = get(MapOverrideParameter);
    if (map_override) {
      Juke.logger.info('Using override map:', map_override);
      defines.push("MAP_OVERRIDE");
    }
    if (defines.length > 0) {
      Juke.logger.info('Using defines:', defines.join(', '));
    }
    if (includes.length > 0) {
      Juke.logger.info('Using injected includes:', defines.join(', '));
    }
    await DreamMaker(`${DME_NAME}.dme`, {
      defines: ['CBT', ...defines],
      includes: [...includes],
      mapOverride: map_override,
    });
  },
});

export const DmTestTarget = new Juke.Target({
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_MAPS') && DmMapsIncludeTarget,
  ],
  executes: async ({ get }) => {
    const defines = get(DefineParameter);
    const map_override = get(MapOverrideParameter);
    if (map_override) {
      Juke.logger.info('Using override map:', map_override);
      defines.push("MAP_OVERRIDE");
    }
    if (defines.length > 0) {
      Juke.logger.info('Using defines:', defines.join(', '));
    }
    fs.copyFileSync(`${DME_NAME}.dme`, `${DME_NAME}.test.dme`);
    await DreamMaker(`${DME_NAME}.test.dme`, {
      defines: ['CBT', 'CIBUILDING', 'UNIT_TEST', ...defines],
      mapOverride: map_override,
    });
    Juke.rm('data/logs/ci', { recursive: true });
    await DreamDaemon(
      `${DME_NAME}.test.dmb`,
      '-close', '-trusted', '-verbose',
      '-params', 'log-directory=ci'
    );
    Juke.rm('*.test.*');
    try {
      const cleanRun = fs.readFileSync('data/logs/ci/clean_run.lk', 'utf-8');
      console.log(cleanRun);
    }
    catch (err) {
      Juke.logger.error('Test run was not clean, exiting');
      throw new Juke.ExitCode(1);
    }
  },
});

export const YarnTarget = new Juke.Target({
  inputs: [
    'tgui/.yarn/+(cache|releases|plugins|sdks)/**/*',
    'tgui/**/package.json',
    'tgui/yarn.lock',
  ],
  outputs: [
    'tgui/.yarn/install-target',
  ],
  executes: async () => {
    await yarn('install');
  },
});

export const TguiTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  inputs: [
    'tgui/.yarn/install-target',
    'tgui/webpack.config.js',
    'tgui/**/package.json',
    'tgui/packages/**/*.+(js|cjs|ts|tsx|scss)',
  ],
  outputs: [
    'tgui/public/tgui.bundle.css',
    'tgui/public/tgui.bundle.js',
    'tgui/public/tgui-panel.bundle.css',
    'tgui/public/tgui-panel.bundle.js',
  ],
  executes: async () => {
    await yarn('webpack-cli', '--mode=production');
  },
});

export const TguiEslintTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: async ({ args }) => {
    await yarn(
      'eslint', 'packages',
      '--fix', '--ext', '.js,.cjs,.ts,.tsx',
      ...args
    );
  },
});

export const TguiTscTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: async () => {
    await yarn('tsc');
  },
});

export const TguiTestTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: async ({ args }) => {
    await yarn('jest', ...args);
  },
});

export const TguiLintTarget = new Juke.Target({
  dependsOn: [YarnTarget, TguiEslintTarget, TguiTscTarget, TguiTestTarget],
});

export const TguiDevTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: async ({ args }) => {
    await yarn('node', 'packages/tgui-dev-server/index.js', ...args);
  },
});

export const TguiAnalyzeTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: async () => {
    await yarn('webpack-cli', '--mode=production', '--analyze');
  },
});

export const TestTarget = new Juke.Target({
  dependsOn: [DmTestTarget, TguiTestTarget],
});

export const LintTarget = new Juke.Target({
  dependsOn: [TguiLintTarget],
});

export const BuildTarget = new Juke.Target({
  dependsOn: [TguiTarget, DmTarget],
});

export const ServerTarget = new Juke.Target({
  dependsOn: [BuildTarget],
  executes: async ({ get }) => {
    const port = get(PortParameter) || '1337';
    await DreamDaemon(`${DME_NAME}.dmb`, port, '-trusted');
  },
});

export const AllTarget = new Juke.Target({
  dependsOn: [TestTarget, LintTarget, BuildTarget],
});

/**
 * Removes the immediate build junk to produce clean builds.
 */
export const CleanTarget = new Juke.Target({
  executes: async () => {
    Juke.rm('*.dmb');
    Juke.rm('*.rsc');
    Juke.rm('*.mdme');
    Juke.rm('*.mdme*');
    Juke.rm('*.m.*');
    Juke.rm('maps/templates.dm');
    Juke.rm('tgui/public/.tmp', { recursive: true });
    Juke.rm('tgui/public/*.map');
    Juke.rm('tgui/public/*.chunk.*');
    Juke.rm('tgui/public/*.bundle.*');
    Juke.rm('tgui/public/*.hot-update.*');
    Juke.rm('tgui/.yarn/cache', { recursive: true });
    Juke.rm('tgui/.yarn/unplugged', { recursive: true });
    Juke.rm('tgui/.yarn/webpack', { recursive: true });
    Juke.rm('tgui/.yarn/build-state.yml');
    Juke.rm('tgui/.yarn/install-state.gz');
    Juke.rm('tgui/.yarn/install-target');
    Juke.rm('tgui/.pnp.*');
  },
});

/**
 * Removes more junk at expense of much slower initial builds.
 */
export const DistCleanTarget = new Juke.Target({
  dependsOn: [CleanTarget],
  executes: async () => {
    Juke.logger.info('Cleaning up data/logs');
    Juke.rm('data/logs', { recursive: true });
    Juke.logger.info('Cleaning up bootstrap cache');
    Juke.rm('tools/bootstrap/.cache', { recursive: true });
    Juke.logger.info('Cleaning up global yarn cache');
    await yarn('cache', 'clean', '--all');
  },
});

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
const prependDefines = (...defines) => {
  const dmeContents = fs.readFileSync(`${DME_NAME}.dme`);
  const textToWrite = defines.map(define => `#define ${define}\n`);
  fs.writeFileSync(`${DME_NAME}.dme`, `${textToWrite}\n${dmeContents}`);
};

export const TgsTarget = new Juke.Target({
  dependsOn: [TguiTarget],
  executes: async () => {
    Juke.logger.info('Prepending TGS define');
    prependDefines('TGS');
  },
});

const TGS_MODE = process.env.CBT_BUILD_MODE === 'TGS';

export default TGS_MODE ? TgsTarget : BuildTarget;
