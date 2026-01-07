// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IAngelSEED {
    error ZeroAddress();
    error MaxSupplyExceeded();
    error InvalidAmount();
    error InvalidReason();
    error ArrayLengthMismatch();
    error EmptyArrays();
    error AdminMustBeContract();

    event RewardMint(address indexed to, uint256 amount, string reason);
    event RoleGranted(uint256 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(uint256 indexed role, address indexed account, address indexed sender);
    event Burn(address indexed from, uint256 amount);

    function rewardMint(address to, uint256 amount, string calldata reason) external;

    function batchRewardMint(address[] calldata recipients, uint256[] calldata amounts, string calldata reason)
        external;

    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function pause() external;

    function unpause() external;

    function grantRoles(address user, uint256 roles) external payable;

    function revokeRoles(address user, uint256 roles) external payable;

    function getMaxSupply() external pure returns (uint256);

    function hasRole(uint256 role, address user) external view returns (bool);

    function isOwnerMultisig() external view returns (bool);
}
