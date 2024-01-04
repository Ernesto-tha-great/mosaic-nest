// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract FracEstate is ERC4626, Ownable {
    using SafeERC20 for ERC20;

    ERC20 public immutable asset_;
    bool public vaultPaused;

    mapping(address => uint256) public shareholders;

    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC4626(_asset) ERC20(_name, _symbol) {
        asset_ = _asset;
        vaultPaused = false;
    }

    modifier vaultActive() {
        if (vaultPaused) {
            revert vaultInactive();
        }
        _;
    }

    function vaultInactive() internal pure {
        revert("Vault is inactive");
    }

    function pauseValut() external onlyOwner {
        vaultPaused = true;
    }

    function activateVault() external onlyOwner {
        vaultPaused = false;
    }

    /// deposit and withdraw functions
    function deposit(ERC20 asset, uint256 _receiver) public virtual override vaultActive returns (ERC20 shares) {
        SafeERC20.safeTransferFrom(msg.sender, address(this), asset);

        // Mint shares to depositor
        _mint(receiver, asset);
        shareholders[msg.sender] += _asset;
    }

    function mint(uint256 shares, address receiver) public virtual override vaultActive returns (uint256 asset) {
        SafeERC20.safeTransferFrom(msg.sender, address(this), asset);

        // Mint shares to depositor
        _mint(receiver, asset);
        shareholders[msg.sender] += _asset;
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        virtual
        override
        vaultActive
        returns (uint256 shares)
    {
        // Burn shares from depositor
        _burn(owner, assets);
        shareholders[msg.sender] -= _asset;

        // Transfer assets to depositor
        SafeERC20.safeTransfer(receiver, asset);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        override
        vaultActive
        returns (uint256 assets)
    {
        // Burn shares from depositor
        _burn(owner, shares);
        shareholders[msg.sender] -= _asset;

        // Transfer assets to depositor
        SafeERC20.safeTransfer(receiver, asset);
    }

    /// accounting functions
    function totalAssets() public virtual override vaultActive returns (uint256) {
        return asset_.balanceOf(address(this));
    }

    function convertToShares(uint256 assets) public view virtual override vaultActive returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view virtual override vaultActive returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function previewDeposit(uint256 assets) public view virtual override vaultActive returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual override vaultActive returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 assets) public view virtual override vaultActive returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual override vaultActive returns (uint256) {
        return convertToAssets(shares);
    }

    /// deposit/withdrawal limit logic

    function maxDeposit(address) public view virtual override vaultActive returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual override vaultActive returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual override vaultActive returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual override vaultActive returns (uint256) {
        return balanceOf[owner];
    }
}
