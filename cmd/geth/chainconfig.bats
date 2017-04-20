#!/usr/bin/env bats

: ${GETH_CMD:=$GOPATH/bin/geth}

setup() {
	DATA_DIR=`mktemp -d`
}

teardown() {
	rm -fr $DATA_DIR
}

# Test dumping chain configuration to JSON file.
@test "chainconfig default dump" {
	run $GETH_CMD --datadir $DATA_DIR --maxpeers 0 dumpExternalChainConfig $DATA_DIR/dump.json
	echo "$output"

	[ "$status" -eq 0 ]
	[[ "$output" == *"Wrote chain config file"* ]]
	[ -f $DATA_DIR/dump.json ]
	[ -d $DATA_DIR/mainnet ]

	run grep -R "mainnet" $DATA_DIR/dump.json
	[ "$status" -eq 0 ]
	[[ "$output" == *"\"name\": \"mainnet\"," ]]
}

@test "chainconfig testnet dump" {
	run $GETH_CMD --datadir $DATA_DIR --testnet dumpExternalChainConfig $DATA_DIR/dump.json
	echo "$output"

	[ "$status" -eq 0 ]
	[[ "$output" == *"Wrote chain config file"* ]]
	[ -f $DATA_DIR/dump.json ]
	[ -d $DATA_DIR/testnet ]

	run grep -R "testnet" $DATA_DIR/dump.json
	[[ "$output" == *"\"name\": \"testnet\"," ]]
}

@test "chainconfig customnet dump" {
	run $GETH_CMD --datadir $DATA_DIR --chain kittyCoin dumpExternalChainConfig $DATA_DIR/dump.json
	echo "$output"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Wrote chain config file"* ]]
	
	# Ensure JSON dump file and named subdirectory (conainting chaindata) exists.
	[ -f $DATA_DIR/dump.json ]
	[ -d $DATA_DIR/kittyCoin ]

	# Ensure we're using the --chain named subdirectory under main $DATA_DIR
	run grep -R "kittyCoin" $DATA_DIR/dump.json
	[ "$status" -eq 0 ]
	[[ "$output" == *"\"name\": \"kittyCoin\"," ]]
}

# Test loading chain configuration from JSON file.
@test "chainconfig configurable from file" {
	cp -R $BATS_TEST_DIRNAME/../../cmd/geth/testdata/chain_config_dump-ok.json $DATA_DIR/

	# Ensure non-default nonce (42 is default).
	run $GETH_CMD --datadir $DATA_DIR --chainconfig $DATA_DIR/chain_config_dump-ok.json --maxpeers 0 --nodiscover --nat none --ipcdisable --exec 'eth.getBlock(0).nonce' console
	echo "$output"
	[[ "$output" == *'"0x0000000000000043"'* ]]

	# Ensure we're using the --chain named subdirectory under main $DATA_DIR.
	[ -d $DATA_DIR/codetestnet ]
}


















