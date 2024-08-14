const path = require('path');

module.exports = {
  entryPoints: ['src/javascript/index.js'],
  bundle: true,
  outfile: 'dist/phlex_chatbot.js',
  loader: { '.js': 'jsx' },
  target: ['es2015'],
  sourcemap: true,
  plugins: [
    {
      name: 'stimulus-loader',
      setup(build) {
        build.onResolve({ filter: /controllers\/.*\.js$/ }, args => {
          return { path: path.resolve(args.resolveDir, args.path) };
        });
      },
    },
  ],
};