/*
 * TestPetshop.sol
 * Solidity code for testing the Petshop contract
 * Editor: Weixuan Yang
 * Date: August 22, 2022
*/

pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Petshop.sol";

contract TestPetshop {
Petshop petshop = Petshop(DeployedAddresses.Petshop()); // The address of the adoption contract to be tested
address expectedOwner = address(this); //The expected owner of the pet is this contract
uint expectedPetId = petshop.petn(); // The id of the new pet that that will be tested
uint expectedSupplyId = petshop.supplyn(); // The id of the new supply that that will be tested
uint expectedPetPrice = 2; // The price of the new pet expected 
uint expectedSupplyPrice = 2; // The price of the new supply expected 
uint expectedOwnPetTotal = 0; // The total woned pet expected
uint expectedUserTotal = 0; // The total user count expected
uint expectedPetVote; // The vote number of a pet expected
uint expectedSupplyStock; // The stock number of a supplyexpected

/*
 * Pet related test functions
 */

function testUserCanAddPet() public {
/* Test the add pet function */
  uint returnedId = petshop.addPetPublic("Jeanine", "French Bulldog", 2, "Gerber, South Dakota", expectedPetPrice, "images/french-bulldog.jpeg");
  Assert.equal(returnedId, expectedPetId, "Adding of the expected pet should match what is returned.");
}
 
function testStatisticsAfterAddPet() public {
/* Test the statistics data after adding a pet */
  expectedUserTotal ++; // increase the expected total user count by 1 for adding a pet
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should be increased by 1.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should stays the same.");
}

function testAddedPet() public {
/* Test the metadata of the added pet */
  ( , string memory _name, string memory _breed, uint _age, string memory _location, uint _price, string memory _image, uint _vote) = petshop.pets(expectedPetId);
  Assert.equal(_name, "Jeanine", "The name of the added pet should match.");
  Assert.equal(_breed, "French Bulldog", "The breed of the added pet should match.");
  Assert.equal(_age, 2, "The age of the added pet should match.");
  Assert.equal(_location, "Gerber, South Dakota", "The location of the added pet should match.");
  Assert.equal(_price, expectedPetPrice, "The price of the added pet should match.");
  Assert.equal(_image, "images/french-bulldog.jpeg", "The image of the added pet should match.");
  Assert.equal(_vote, 0, "The vote count of the added pet should be 0 at started.");
}

function testUserCanAdoptPet() public {
/* Test the adopt pet function */
  uint returnedId = petshop.adoptPet(expectedPetId);
  Assert.equal(returnedId, expectedPetId, "Adoption of the expected pet should match what is returned.");
}

function testUserOwnedAfterAdoptPet() public {
/* Test the owner of the pet after adopting */
  address[16] memory owners = petshop.getOwners();
  Assert.equal(owners[expectedPetId], expectedOwner, "Owner of the expected pet should be this contract");
}

function testStatisticsAfterAdoptPet() public {
/* Test the statistics data after adopting a pet */
  expectedUserTotal ++; // increase the expected total user count by 1 for adopting
  expectedOwnPetTotal ++; // increase the expected owned pet count by 1 for adopting
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should be increased by 1.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should be increased by 1.");
}

function testUserCanReturnAfterAdoptPet() public {
/* Test the return pet function after adopt */
  uint returnedId = petshop.returnPet(expectedPetId);
  Assert.equal(returnedId, expectedPetId, "Adopting of the expected pet should match what is returned.");
}

function testNotOwnedPetAfterAdoptAndReturnPet() public {
/* Test the owner of the pet after adopting and returning */
  address[16] memory owners = petshop.getOwners();
  Assert.equal(owners[expectedPetId], 0x0000000000000000000000000000000000000000, "Owner of the expected pet should be empty");
}

function testStatisticsAfterAdoptAndReturnPet() public {
/* Test the statistics data after adopting and returning for a pet */
  expectedOwnPetTotal --; // decrease the expected owned pet count by 1 for returning a pet
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should stays the same.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should be decrease by 1 when returning.");
}

function testPricePet() public {
/* Test if the expected price match the current price of the pet */
  uint price = petshop.getPetPrice(expectedPetId);
  Assert.equal(price, expectedPetPrice, "Buying of the expected pet should match what is returned.");
}

function testUserCanBuyPet() public {
/* Test the buy pet function */
  uint returnedId = petshop.buyPet(expectedPetId);
  Assert.equal(returnedId, expectedPetId, "Buying of the expected pet should match what is returned.");
}

function testUserOwnedPetAfterBuyPet() public {
/* Test the owner of the pet after buying */
  address[16] memory owners = petshop.getOwners();
  Assert.equal(owners[expectedPetId], expectedOwner, "Owner of the expected pet should be this contract");
}

function testStatisticsAfterBuyPet() public {
/* Test the statistics data after buying for a pet */
  expectedUserTotal ++; // increase the expected total user count by 1 for buying a pet
  expectedOwnPetTotal ++; // increase the expected owned pet count by 1 for buying a pet
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should be increased by 1.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should be increased by 1.");
}

function testUserCanReturnPetAfterBuyPet() public {
/* Test the return pet function after buy */
  uint returnedId = petshop.returnPet(expectedPetId);
  Assert.equal(returnedId, expectedPetId, "Adopting of the expected pet should match what is returned.");
}

function testNotOwnedPetAfterBuyAndReturnPet() public {
/* Test the owner of the pet after buying and returning */
  address[16] memory owners = petshop.getOwners();
  Assert.equal(owners[expectedPetId], 0x0000000000000000000000000000000000000000, "Owner of the expected pet should be empty");
}

function testStatisticsAfterBuyAndReturnPet() public {
/* Test the statistics data after buying and returning for a pet */
  expectedOwnPetTotal --; // decrease the expected owned pet count by 1 for returning the pet
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should stays the same.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should be decrease by 1 when returning.");
}

function testUserCanVoteForPet() public {
/* Test the buy pet function */
  expectedPetVote = petshop.getPetVote(expectedPetId) + 1; // preload the vote count of the pet before voting
  uint returnedId = petshop.votePet(expectedPetId);
  Assert.equal(returnedId, expectedPetId, "Voting for the expected pet should match what is returned.");
}

function testVoteCountPet() public {
/* Test the vote count increment after voting */
  uint vote = petshop.getPetVote(expectedPetId);
  Assert.equal(vote, expectedPetVote, "Voting for the expected pet should increase the vote count of the pet.");
}

function testUserCannotRepeatVotePet() public {
/* Test for avoid repeat voting */
  bool voted = petshop.getVoted();
  Assert.equal(voted, true, "Voted users should be flagged as voted");
}

function testStatisticsAfterVotePet() public {
/* Test the statistics data after vote for a pet */
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should stays the same.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should stays the same.");
}

/*
 * Supply related test functions
 */

function testUserCanAddSupply() public {
/* Test the add supply function */
  uint returnedId = petshop.addSupplyPublic("Dog Food For Testing", 10, expectedSupplyPrice, "images/salmon-dog-food.jpeg");
  Assert.equal(returnedId, expectedSupplyId, "Adding of the expected supply should match what is returned.");
}

function testStatisticsAfterAddSupply() public {
/* Test the statistics data after adding a supply */
  expectedUserTotal ++; // increase the total user count by 1 for adding a supply
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should stays the same.");
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should be increased by 1.");
}

function testAddedSupply() public {
/* Test the metadata of the added supply */
  ( , string memory _name, uint _stock, uint _price, string memory _image) = petshop.supplies(expectedSupplyId);
  Assert.equal(_name, "Dog Food For Testing", "The name of the added supply should match.");
  Assert.equal(_stock, 10, "The stock of the added supply should match.");
  Assert.equal(_price, expectedSupplyPrice, "The price of the added supply should match.");
  Assert.equal(_image, "images/salmon-dog-food.jpeg", "The image of the added supply should match.");
}

function testPriceSupply() public {
/* Test if the expected price match the current price of the supply */
  uint price = petshop.getSupplyPrice(expectedSupplyId);
  Assert.equal(price, expectedSupplyPrice, "Buying of the expected supply should match what is returned.");
}

function testUserCanBuySupply() public {
/* Test the buy supply function */
  expectedSupplyStock = petshop.getSupplyStock(expectedSupplyId) - 1; // preload the stock left of the supply before buying
  uint returnedId = petshop.buySupply(expectedSupplyId);
  Assert.equal(returnedId, expectedSupplyId, "Buying of the expected supply should match what is returned.");
}

function testStockCountAfterBuySupply() public {
/* Test the stock number after buying a supply */
  uint stock = petshop.getSupplyStock(expectedSupplyId);
  Assert.equal(stock, expectedSupplyStock, "Buying of the expected supply should reduce its stock number by one.");
}

function testStatisticsAfterBuyupply() public {
/* Test the statistics data after buying a supply */
  expectedUserTotal ++; // increase the total user count by 1 for buying a supply
  Assert.equal(petshop.userTotal(), expectedUserTotal, "The customer served should be increased by 1.");
  Assert.equal(petshop.ownPetTotal(), expectedOwnPetTotal, "The total adopted pet should stays the same.");
}

}
