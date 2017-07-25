pragma solidity ^0.4.11;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract IFundraiser {
    uint256 public tokensPerEth;
    function issue(address recipient, uint256 amount);
}


// Issuance of loyalty bonus for donors that participated in the old fundraiser
contract Bonus is Ownable {
  address public fundraiser;
  bool public issuanceDone;

  // for ference
  uint256 public bonusRate;           // exchange rate used (tokens per ETH)
  uint256 public issuanceBlocknumber; // block number in which tokens were issued
  uint256 public bonusMultiplier = 2; // 2x extra tokens per ETH

  struct Donation {
    address donor;
    uint256 amount;
  }

  Donation[] public donors;

  event LogBonusIssued(address recipient, uint256 ethAmount, uint256 tokens);
  event LogIssuanceCompleted();

  function Bonus() {}

  function donorCount() public constant returns (uint256) {
    return donors.length;
  }

  // Init donor array with all ether amounts of donations from old fundraiser
  function initDonors() external onlyOwner {
    require(donorCount() == 0);
    require(fundraiser != address(0));
    donors.push(Donation(0x55B30722d84ca292E4432f644F183D1986D2B8F9, 100000000000000000));
    donors.push(Donation(0x7AB6C31747049BBe34a19253c0abe5001cCBe8c6, 4900000000000000000));
    donors.push(Donation(0xF851ff5037212C716e91CD474252B86faCa7bb11, 2958098700000000000));
    donors.push(Donation(0x27ed1A21a243C8CdE077e64014E9E438D8D21482, 150000000000000000));
    donors.push(Donation(0x1697c3c6b4359124C1b2A8fB85114c67B6491965, 1000000000000000000));
    donors.push(Donation(0x413864b3Fbc9a59a73205C85C1d69be0220a8D6f, 1000000000000000000));
    donors.push(Donation(0x008f2e1AD8ED95040D64Ab9e8D8f3eef7e4e991A, 3000000000000000000));
    donors.push(Donation(0xe96c7892f11304b9d04a96d6FF6edF9B573b2093, 315676430000000000));
    donors.push(Donation(0xc44CA6Ec87A229F61f9C8d4fEBa81dcF51a666dD, 1000000000000000));
    donors.push(Donation(0x4e1997a0728bB99ab63e1a39957EE8D9349b0798, 200000000000000000));
    donors.push(Donation(0x88Ad1eA01e9635EcaDCFF10A19C05d1B1cbe90B9, 1000000000000000000));
    donors.push(Donation(0x7cB57B5A97eAbe94205C07890BE4c1aD31E486A8, 1000000000000000));
    donors.push(Donation(0x3aEd77b7F19f7e0953D4c64a7859699145dbBCCE, 405000000000000000));
    donors.push(Donation(0x22021bB4404A637Cc82CBff53bd30f9c16083095, 200000000000000000));
    donors.push(Donation(0x001D8D7dd820e22cE63E6D86D4A48346BA13C154, 1000000000000000000));
    donors.push(Donation(0x3E8A92020d6EF10412b93E52220C68d8f0548a9C, 1000000000000000000));
    donors.push(Donation(0x5043732862627D7b00648D385637A46ff02d41f2, 1000000000000000000));
    donors.push(Donation(0xDa33a97A4fAc818d250832D9708cAE99a487222d, 2000000000000000000));
    donors.push(Donation(0xfE78Be20FeeE8f6d1F64b4731d16ca046A1F625c, 250000000000000000));
    donors.push(Donation(0x9cF947C47fB8E83006233d6b5f1d7F0e8cEDaacc, 3000000000000000000));
    donors.push(Donation(0x9f15F58C4161C5Cf0C1B8139a642e108e8eF2C29, 50000000000000000));
    donors.push(Donation(0x19006Ef9a48f9EA094cCcBA94559266D48FEfF06, 2000000000000000000));
    donors.push(Donation(0xC48A6de82842B531DA08b27ca3CF7A95AbD21b37, 25000000000000000000));
    donors.push(Donation(0x00f6be63D0847351A891cD43750c245743308D75, 2000000000000000));
    donors.push(Donation(0xdD1240c4A131cB0B037Ac45FfB43b7499f2B164d, 500000000000000000));
    donors.push(Donation(0xc5C456aF2844F610F61e996B83Ec0eD98faa092D, 2000000000000000000));
    donors.push(Donation(0x949D6642066DEC1C937aAca4Ec3C2c04Fcc0C2AA, 1346679000000000000));
    donors.push(Donation(0xf15E59eccD96E7fC7421ecdf36C100273007E654, 3990000000000000000));
    donors.push(Donation(0x444F63f3661919cE69cfCE67a2f8BAc5A170cadD, 1000000000000000000));
    donors.push(Donation(0xd45546Cbc3C4dE75CC2B1f324d621A7753f25bB3, 200000000000000000));
    donors.push(Donation(0xeb3C4E9706064e66358b8c17C351c110Be34F9C7, 1000000000000000000));
    donors.push(Donation(0xfC9455179760fEE65B1F82162ebD96cbb626e1b6, 1000000000000000000));
    donors.push(Donation(0xE94aE3d286F693A313c7C8A0907c2f425ADb80C9, 84356750000000000));
    donors.push(Donation(0xAc3949c90Aca5e543114b242917426eF78dae650, 74766400000000000));
    donors.push(Donation(0x6541875114bEca413d016fb60B2Aa25e14604d20, 121800000000000000000));

    initBonusRate();
  }

  /// @dev convert a given amount of eth to tokens
  /// @param amount amount in ether
  /// @param rate   exchange rate
  // safe math not needed here since we know exactly what the amounts will be
  function ethToTokens(uint256 amount, uint256 rate) internal returns (uint256) {
    return (amount * rate) / 10**18;
  }

  /// @dev set a new fundraiser address in which tokens will be issued
  /// @param _fundraiser a fundraiser address
  function setFundraiserAddress(address _fundraiser) external onlyOwner {
    require(!issuanceDone);
    require(_fundraiser != address(0));
    fundraiser = _fundraiser;
  }

  function initBonusRate() internal {
    require(bonusRate == 0); // not already initalized
    IFundraiser fundraiserInstance = IFundraiser(fundraiser);
    bonusRate = uint256(fundraiserInstance.tokensPerEth()) * bonusMultiplier;
    assert(bonusRate > 0);
  }

  function numTokensToCreate() external constant returns (uint256) {
    uint256 sum = 0;
    for (uint i = 0; i < donors.length; i++) {
      sum += ethToTokens(donors[i].amount, bonusRate);
    }

    return sum;
  }

  // Issue tokens to donors, can only be executed successfully once
  function createBonusTokens() external onlyOwner {
    require(donorCount() > 0 && bonusRate > 0);
    require(fundraiser != address(0));
    require(!issuanceDone);
    uint256 numDonors = donorCount();
    IFundraiser fundraiserInstance = IFundraiser(fundraiser);

    for (uint i = 0; i < numDonors; i++) {
      Donation storage donation = donors[i];
      uint256 tokenAmount = ethToTokens(donation.amount, bonusRate);
      fundraiserInstance.issue(donation.donor, tokenAmount);
      LogBonusIssued(donation.donor, donation.amount, tokenAmount);
    }

    issuanceDone = true;
    issuanceBlocknumber = block.number;
    LogIssuanceCompleted();
  }
}
