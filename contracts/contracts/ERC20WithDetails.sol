// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20WithDetails is ERC20 {
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    event TransferDetails(address indexed from, address indexed to, uint256 amount, bytes details);

    address private owner;
    uint256 private constant INITIAL_SUPPLY = 10000000000000;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    constructor() ERC20("ERC20 with details", "DETS") {
        _mint(msg.sender, INITIAL_SUPPLY);

        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public isOwner {
        owner = newOwner;
        emit OwnerSet(owner, newOwner);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferDetails(address to, uint256 amount, bytes memory details)
            public returns (bool) {
        bool result = super.transfer(to, amount);
        if(result) {
            emit TransferDetails(msg.sender, to, amount, details);
        }
        return result;
    }

    function transfer(address to, uint256 amount) public
            virtual override returns (bool) {
        return transferDetails(to, amount, "");
    }

    function transferFromDetails(address from, address to, uint256 amount,
                                 bytes memory details)
            public returns (bool) {
        bool result = super.transferFrom(from, to, amount);
        if(result) {
            emit TransferDetails(from, to, amount, details);
        }
        return result;
    }

    function transferFrom(address from, address to, uint256 amount)
            public virtual override returns (bool)  {
        return transferFromDetails(from, to, amount, "");
    }

    function newCoins() public isOwner {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
