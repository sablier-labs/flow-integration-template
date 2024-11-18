// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD21x18 } from "@prb/math/src/UD21x18.sol";
import { ISablierFlow } from "@sablier/flow/src/interfaces/ISablierFlow.sol";

/// @title FlowStreamCreator
/// @dev This contract allows users to create Sablier flow streams.
contract FlowStreamCreator {
    IERC20 public constant DAI = IERC20(0x68194a729C2450ad26072b3D33ADaCbcef39D574);
    ISablierFlow public immutable FLOW;

    constructor(ISablierFlow flow) {
        FLOW = flow;
    }

    /// @notice Creates a new Sablier flow stream without upfront deposit.
    function createFlowStream() external returns (uint256 streamId) {
        address sender = msg.sender; // The sender will be able to pause the stream or change rate per second. To see a
            // full
            // list of permissions, check the Sablier docs
        address recipient = address(0xcafe); // The recipient of the streamed assets
        UD21x18 ratePerSecond = UD21x18.wrap(11_574_074_074_074_073e16); // Equivalent to 100e18 DAI per day
        IERC20 token = DAI; // The streaming token
        bool transferable = true; // Whether the stream will be transferable or not

        // Create the flow stream using the `create` function.
        streamId = FLOW.create(sender, recipient, ratePerSecond, token, transferable);
    }

    /// @notice Creates a new Sablier flow stream with some upfront deposit.
    /// @dev Before calling this function, the user must first approve this contract to spend the tokens from the user's
    /// address.
    function createFlowStreamAndDeposit(uint128 depositAmount) external returns (uint256 streamId) {
        // Transfer the provided amount of DAI tokens to this contract
        DAI.transferFrom(msg.sender, address(this), depositAmount);

        // Approve the Flow contract to spend DAI
        DAI.approve(address(FLOW), depositAmount);

        address sender = msg.sender; // The sender will be able to pause the stream or change rate per second. To see a
            // full list of permissions, check the Sablier docs
        address recipient = address(0xcafe); // The recipient of the streamed assets
        UD21x18 ratePerSecond = UD21x18.wrap(11_574_074_074_074_073e16); // Equivalent to 100e18 DAI per day
        IERC20 token = DAI; // The streaming token
        bool transferable = true; // Whether the stream will be transferable or not

        // Create the flow stream using the `createAndDeposit` function which would also deposit tokens into the stream.
        streamId = FLOW.createAndDeposit(sender, recipient, ratePerSecond, token, transferable, depositAmount);
    }
}
