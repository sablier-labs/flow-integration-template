// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Test } from "forge-std/src/Test.sol";
import { ISablierFlow } from "@sablier/flow/src/interfaces/ISablierFlow.sol";

import { FlowStreamCreator } from "../src/FlowStreamCreator.sol";

contract FlowStreamCreatorTest is Test {
    // Get the latest deployment address from the docs: https://docs.sablier.com/guides/flow/deployments
    address internal constant FLOW_ADDRESS = address(0x83Dd52FCA44E069020b58155b761A590F12B59d3);

    // Test contracts
    FlowStreamCreator internal creator;
    ISablierFlow internal flow;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet
        vm.createSelectFork({ blockNumber: 6_964_132, urlOrAlias: "sepolia" });

        // Load the flow contract from Ethereum sepolia
        flow = ISablierFlow(FLOW_ADDRESS);

        // Deploy the stream creator contract
        creator = new FlowStreamCreator(flow);

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user.
        deal({ token: address(creator.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });
    }

    function test_CreateFlowStream() public {
        uint256 expectedStreamId = flow.nextStreamId();
        uint256 actualStreamId = creator.createFlowStream();

        // Check that creating flow stream works by checking the stream ids
        assertEq(actualStreamId, expectedStreamId);

        // Check that stream is created with no initial balance
        assertEq(flow.getBalance(actualStreamId), 0);
    }

    function test_CreateFlowStreamAndDeposit() public {
        // Approve the creator contract to pull DAI tokens from the test user
        creator.DAI().approve({ spender: address(creator), value: 1337e18 });

        uint256 expectedStreamId = flow.nextStreamId();
        uint256 actualStreamId = creator.createFlowStreamAndDeposit({ depositAmount: 1337e18 });

        // Check that creating flow stream works by checking the stream ids
        assertEq(actualStreamId, expectedStreamId);

        // Check that the stream is created with the deposit balance
        assertEq(flow.getBalance(actualStreamId), 1337e18);
    }
}
