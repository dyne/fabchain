#!/usr/bin/env zenroom
--
--Private blockchain genesis for Geth 1.17 using EIP-225
--docs: https://geth.ethereum.org/docs/interface/private-network
--requires Zenroom: https://zenroom.org
--
--Copyright (C) 2021 Dyne.org foundation
--designed, written and maintained by Denis Roio
--
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU Affero General Public License v3.0
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Affero General Public License for more details.
--
--Along with this program you should have received a copy of the
--GNU Affero General Public License v3.0
--If not, see http://www.gnu.org/licenses/agpl.txt

-- initial gas amount given to signers
share = 1048576

-- estimated using https://etherscan.io/chart/gaslimit
gaslimit = 30000000

-- list of public addresses of signers and shareholders
signers = { 'D77136c62F8d62793eaA6a5B26581630AEB4fe2F', -- j
	    '500932db2aaf42b42911b3ddcc80ae25bde94b80', -- a
	    'CA5455Fdd04A47a3F2480570c7794945D7E18B6A'  -- p
	  }

-- clique seconds of threshold for confirmations
period = 5

-- END OF CONFIG

-- render extradata
extradata = '0x'..O.zero(32):hex()
for k,v in pairs(signers) do extradata = extradata .. k end
extradata = extradata .. O.zero(65):hex()

-- render initial signer accounts
accounts = { }
for k,v in ipairs(signers) do
   accounts[v] = { balance = tostring(share) }
end

genesis = {
   config = {
      chainId= 1146703429,
      homesteadBlock = 0,
      eip150Block = 0,
      eip155Block = 0,
      eip158Block = 0,
      byzantiumBlock = 0,
      constantinopleBlock = 0,
      petersburgBlock = 0,
      clique = {
	 period = period,
	 epoch = 30000
      }
   },
   difficulty = tostring(1),
   gasLimit = tostring(gaslimit),
   extradata = '0x'..extradata .. O.zero(65):hex(),
   alloc = accounts
}

print( JSON.encode(genesis) )
