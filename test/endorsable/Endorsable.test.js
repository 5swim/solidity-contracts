const Signable = artifacts.require("Endorsable");

contract("Endorsable", accounts => {
    it("Test something random", () =>
    Signable.deployed()
      .then(instance => instance.getBalance.call(accounts[0]))
      .then(balance => {
        assert.equal(
          balance.valueOf(),
          10000,
          "10000 wasn't in the first account"
        );
      }));
});
