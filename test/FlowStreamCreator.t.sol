// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Test } from "forge-std/src/Test.sol";

import { FlowStreamCreator } from "../src/FlowStreamCreator.sol";

contract FlowStreamCreatorTest is Test {
    // Test contracts
    FlowStreamCreator internal creator;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet at the latest block
        vm.createSelectFork({ urlOrAlias: "mainnet" });

        // Deploy the stream creator contract
        creator = new FlowStreamCreator();

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user.
        deal({ token: address(creator.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });
    }

    function test_CreateFlowStream() public {
        uint256 expectedStreamId = creator.FLOW().nextStreamId();
        uint256 actualStreamId = creator.createFlowStream();

        // Check that creating flow stream works by checking the stream ids
        assertEq(actualStreamId, expectedStreamId);

        // Check that stream is created with no initial balance
        assertEq(creator.FLOW().getBalance(actualStreamId), 0);
    }

    function test_CreateFlowStreamAndDeposit() public {
        // Approve the creator contract to pull DAI tokens from the test user
        creator.DAI().approve({ spender: address(creator), value: 1337e18 });

        uint256 expectedStreamId = creator.FLOW().nextStreamId();
        uint256 actualStreamId = creator.createFlowStreamAndDeposit({ depositAmount: 1337e18 });

        // Check that creating flow stream works by checking the stream ids
        assertEq(actualStreamId, expectedStreamId);

        // Check that the stream is created with the deposit balance
        assertEq(creator.FLOW().getBalance(actualStreamId), 1337e18);
    }
}
