<img src="https://raw.githubusercontent.com/defi-wonderland/brand/v1.0.0/external/solidity-foundry-boilerplate-banner.png" alt="wonderland banner" align="center" />
<br />

<div align="center"><strong>Start your next Solidity project with Foundry in seconds</strong></div>
<div align="center">A highly scalable foundation focused on DX and best practices</div>

<br />

## Features

<dl>
  <dt>Sample contracts</dt>
  <dd>Basic Greeter contract with an external interface.</dd>

  <dt>Foundry setup</dt>
  <dd>Foundry configuration with multiple custom profiles and remappings.</dd>

  <dt>Deployment scripts</dt>
  <dd>Sample scripts to deploy contracts on both mainnet and testnet.</dd>

  <dt>Sample e2e & unit tests</dt>
  <dd>Example tests showcasing mocking, assertions and configuration for mainnet forking. As well it includes everything needed in order to check code coverage.</dd>

  <dt>Linter</dt>
  <dd>Simple and fast solidity linting thanks to forge fmt</a>.</dd>

  <dt>Github workflows CI</dt>
  <dd>Run all tests and see the coverage as you push your changes.</dd>
  <dd>Export your Solidity interfaces and contracts as packages, and publish them to NPM.</dd>
</dl>

## Setup

1. Install Foundry by following the instructions from [their repository](https://github.com/foundry-rs/foundry#installation).
2. Copy the `.env.example` file to `.env` and fill in the variables.
3. Install the dependencies by running: `yarn install`. In case there is an error with the commands, run `foundryup` and try them again.

## Build

The default way to build the code is suboptimal but fast, you can run it via:

```bash
yarn build
```

In order to build a more optimized code ([via IR](https://docs.soliditylang.org/en/v0.8.15/ir-breaking-changes.html#solidity-ir-based-codegen-changes)), run:

```bash
yarn build:optimized
```

## Running tests

Unit tests should be isolated from any externalities, while E2E usually run in a fork of the blockchain. In this boilerplate you will find example of both.

In order to run both unit and E2E tests, run:

```bash
yarn test
```

In order to just run unit tests, run:

```bash
yarn test:unit
```

In order to run unit tests and run way more fuzzing than usual (5x), run:

```bash
yarn test:unit:deep
```

In order to just run e2e tests, run:

```bash
yarn test:e2e
```

In order to check your current code coverage, run:

```bash
yarn coverage
```

<br>

## Deploy & verify

### Setup

Configure the `.env` variables.

### Goerli

```bash
yarn deploy:goerli
```

### Mainnet

```bash
yarn deploy:mainnet
```

The deployments are stored in ./broadcast

See the [Foundry Book for available options](https://book.getfoundry.sh/reference/forge/forge-create.html).

## Export And Publish

### Export

Export TypeScript interfaces from Solidity contracts and interfaces providing compatibility with TypeChain.

Update the `package_name` in the `solidity-exporter.yml` file to match your package name:

```yaml
# Update package_name with your package name
package_name: "@defi_wonderland/solidity-exported"
```

### Publish

If you want to publish the exported packages to NPM, you can do so by uncommenting the following lines in the `solidity-exporter.yml` file (make sure you've set the `NPM_TOKEN` on your org's secrets) and updating the package name with yours:

```yaml
## Uncomment it if you want to publish your exported packages to NPM
# - name: Publish
## Update `@defi_wonderland/solidity-exported` with your package name
#   run: cd export/@defi_wonderland/solidity-exported-${{ matrix.export_type }} && npm publish --access public
#   env:
#     NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

You can take a look at our [solidity-exporter-action](https://github.com/defi-wonderland/solidity-exporter-action) repository more information and usage examples.
