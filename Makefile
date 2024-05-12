-include .env

.PHONY: test test-fork

test :; forge test

test-fork :; forge test --fork-url ${ETH_MAINNET_RPC_URL} -vvv
