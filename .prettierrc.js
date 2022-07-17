module.exports = {
  overrides: [
    {
      files: '*.sol',
      options: {
        tabWidth: 4,
        printWidth: 80,
        bracketSpacing: true,
        compiler: '0.8.14',
      },
    },
    {
      files: '*.json',
      options: {
        tabWidth: 2,
        printWidth: 200,
      },
    },
  ],
};
