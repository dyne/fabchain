// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0;

contract StorageString {
    uint256 maxlen = 0;
    event HashSaved(string);
    constructor(uint256 _maxlen) {
        maxlen = _maxlen;
    }
    function store(string memory message) public {
        // We are comparing the size in byte, not the length of the
        // string (that is the number of chars)
        require(bytes(message).length <= maxlen, "Message too long");
        emit HashSaved(message);
    }
}
