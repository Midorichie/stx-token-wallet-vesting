# STX Token Vesting Contract

This Clarity smart contract provides a secure and automated system for managing the vesting of STX tokens for one or more beneficiaries.

## Features
- Support for multiple vesting schedules with different start times, durations, and cliff periods
- Ability for beneficiaries to claim their vested tokens at any time after the cliff period has passed
- Tracking of total vested tokens per beneficiary and across all schedules
- Detailed error handling to ensure the contract is used correctly

## Usage

### Initialization
The contract owner can initialize a new vesting schedule using the `initialize-vesting` function. This requires the following parameters:

- `start-block`: The block height at which the vesting period begins
- `duration-blocks`: The total number of blocks over which the tokens will vest
- `cliff-blocks`: The number of blocks before the first portion of tokens can be claimed
- `beneficiary-principal`: The principal address of the beneficiary
- `token-contract`: The ID of the token contract being used for vesting

### Claiming Vested Tokens
Beneficiaries can claim their vested tokens using the `claim-vested-tokens` function. This will automatically calculate the amount of tokens that have vested based on the time elapsed since the start of the vesting period, and transfer those tokens to the beneficiary's account.

### Error Handling
The contract includes the following error codes:
- `err-not-contract-owner`: Thrown when a non-owner tries to initialize a vesting schedule
- `err-tokens-not-vested`: Thrown when a beneficiary tries to claim tokens before the cliff period has elapsed
- `err-no-vesting-schedule`: Thrown when a beneficiary tries to claim tokens but doesn't have a vesting schedule

## Development and Roadmap
This contract was initially developed by [YOUR NAME] and has undergone one major enhancement. Future plans include:

- Ability to modify existing vesting schedules
- Support for partial vesting claims
- Integration with a token lock-up mechanism
- Unit tests and formal verification

Please feel free to submit issues or pull requests on the [GitHub repository](https://github.com/your-username/stx-token-vesting) if you have any feedback or suggestions for improvement.