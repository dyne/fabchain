const Faucet = artifacts.require("Faucet");

contract("Faucet", (accounts) => {
  let faucet

  before(async () => {
      faucet = await Faucet.deployed();
  });

  describe("Transfer some coins", async () => {
    it("increase balance faucet", async () => {
      assert.equal(await web3.eth.getBalance(faucet.address), 
        '0', "The initial balance should be 0eth")

      await web3.eth.sendTransaction({
        to:faucet.address, from:accounts[1], value: web3.utils.toWei('1')})

      assert.equal(await web3.eth.getBalance(faucet.address), 
        '1000000000000000000', "The balance should have been increased by 1eth")
    });

    it("only the owner can change the allowance", async () => {
      const changeOwner = await faucet.setOwner(accounts[1])
      assert.equal(changeOwner.receipt.status, true,
        "Could not change owner")
      assert.equal(await faucet.getOwner(), accounts[1],
        "Owner has not changed")
      try {
        await faucet.setAmountAllowed('1')
        assert.fail("The owner has changed, but the creator can still modify allowance")
      } catch(err) {
        assert.include(err.message, "Only owner can call this function", "The error message should contain 'Only owner can call this function'");
      }
    });

    it("send transaction should fail", async () => {
      const initialBalance = web3.utils.toBN(await web3.eth.getBalance(accounts[3]))
      const amountAllowed = web3.utils.toBN(await faucet.getAmountAllowed())
      await faucet.transfer(accounts[3])
      const finalBalance = web3.utils.toBN(await web3.eth.getBalance(accounts[3]))
      assert.equal(initialBalance.add(amountAllowed).toString(), 
        finalBalance.toString(),
        "Amount allowed not transfered")

      try {
        await faucet.transfer(accounts[3])
        assert.fail("SHould be possible to ask only one transaction per day")
      } catch(err) {
        assert.include(err.message, "lock time has not expired", "The error message should contain 'Lock time has not expired'");
      }
    });
  });
});
