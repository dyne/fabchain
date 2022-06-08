// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0;

contract StorageData {
    uint256 maxlen = 0;
    event HashSaved(bytes);
    constructor(uint256 _maxlen) {
        maxlen = _maxlen;
    }
    function store(bytes memory message) public {
        require(message.length <= maxlen, "Message too long");
        emit HashSaved(message);
    }
}
