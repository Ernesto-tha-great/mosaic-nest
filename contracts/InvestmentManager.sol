// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import {Auth} from "./Auth.sol";
import {SafeTransferLib} from "./utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "./utils/FixedPointMathLib.sol";

interface ERC20Like {
    function approve(address token, address spender, uint256 value) external;
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
    function decimals() external view returns (uint8);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
}

interface LiquidityPoolLike is ERC20Like {
    function poolId() external view returns (uint64);
    function asset_() external view returns (address);
    function share_() external view returns (address);
}

contract InvestmentManager {
    using FixedPointMathLib for uint256;
}
