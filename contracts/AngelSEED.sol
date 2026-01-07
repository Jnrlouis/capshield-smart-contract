// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {OwnableRoles} from "solady/src/auth/OwnableRoles.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IAngelSEED} from "./interfaces/IAngelSEED.sol";

contract AngelSEED is ERC20, OwnableRoles, Pausable, IAngelSEED {
    uint256 public constant REWARD_MINTER_ROLE = _ROLE_0;

    uint256 private constant MAX_SUPPLY = 10_000_000_000 * 10 ** 18;

    uint256 public constant MAX_REASON_LENGTH = 256;

    uint256 private totalMinted;

    constructor(address admin) {
        require(admin != address(0), ZeroAddress());

        require(_isContract(admin), AdminMustBeContract());

        _initializeOwner(admin);
        _grantRoles(admin, REWARD_MINTER_ROLE);

        emit RoleGranted(REWARD_MINTER_ROLE, admin, address(0));
    }

    modifier onlyRole(uint256 role) {
        require(hasAllRoles(msg.sender, role), Unauthorized());
        _;
    }

    function rewardMint(address to, uint256 amount, string calldata reason)
        external
        whenNotPaused
        onlyRole(REWARD_MINTER_ROLE)
    {
        require(to != address(0), ZeroAddress());
        require(amount > 0, InvalidAmount());
        require(totalMinted + amount <= MAX_SUPPLY, MaxSupplyExceeded());
        require(bytes(reason).length > 0 && bytes(reason).length <= MAX_REASON_LENGTH, InvalidReason());

        totalMinted = totalMinted + amount;
        _mint(to, amount);

        emit RewardMint(to, amount, reason);
    }

    function batchRewardMint(address[] calldata recipients, uint256[] calldata amounts, string calldata reason)
        external
        onlyRole(REWARD_MINTER_ROLE)
        whenNotPaused
    {
        require(recipients.length == amounts.length, ArrayLengthMismatch());
        require(recipients.length > 0, EmptyArrays());
        require(bytes(reason).length > 0 && bytes(reason).length <= MAX_REASON_LENGTH, InvalidReason());

        uint256 totalAmount;
        for (uint256 i; i < recipients.length;) {
            require(recipients[i] != address(0), ZeroAddress());
            require(amounts[i] > 0, InvalidAmount());
            totalAmount += amounts[i];
            unchecked {
                ++i;
            }
        }

        require(totalMinted + totalAmount <= MAX_SUPPLY, MaxSupplyExceeded());
        totalMinted += totalAmount;

        for (uint256 i; i < recipients.length;) {
            _mint(recipients[i], amounts[i]);
            emit RewardMint(recipients[i], amounts[i], reason);
            unchecked {
                ++i;
            }
        }
    }

    function burn(uint256 amount) external {
        require(amount > 0, InvalidAmount());
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        require(from != address(0), ZeroAddress());
        require(amount > 0, InvalidAmount());

        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
        emit Burn(from, amount);
    }

    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function grantRoles(address user, uint256 roles) public payable override(IAngelSEED, OwnableRoles) onlyOwner {
        super.grantRoles(user, roles);
        emit RoleGranted(roles, user, msg.sender);
    }

    function revokeRoles(address user, uint256 roles) public payable override(IAngelSEED, OwnableRoles) onlyOwner {
        super.revokeRoles(user, roles);
        emit RoleRevoked(roles, user, msg.sender);
    }

    function transferOwnership(address newOwner) public payable override onlyOwner {
        require(_isContract(newOwner), AdminMustBeContract());
        super.transferOwnership(newOwner);
    }

    function completeOwnershipHandover(address pendingOwner) public payable override onlyOwner {
        require(_isContract(pendingOwner), AdminMustBeContract());
        super.completeOwnershipHandover(pendingOwner);
    }

    function renounceOwnership() public payable override onlyOwner {
        revert("Ownership cannot be renounced");
    }

    function getMaxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }

    function getTotalMinted() external view returns (uint256) {
        return totalMinted;
    }

    function hasRole(uint256 role, address user) external view returns (bool) {
        return hasAllRoles(user, role);
    }

    function DEFAULT_ADMIN_ROLE() external pure returns (bytes32) {
        return bytes32(0);
    }

    function isOwnerMultisig() external view returns (bool) {
        return _isContract(owner());
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function name() public pure override returns (string memory) {
        return "AngelSEED";
    }

    function symbol() public pure override returns (string memory) {
        return "ANGEL";
    }
}
