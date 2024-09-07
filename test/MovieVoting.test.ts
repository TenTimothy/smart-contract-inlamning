import { expect } from "chai";
import { ethers } from "hardhat";
import "solidity-coverage";

describe("MovieVoting", function () {
  let MovieVoting;
  let movieVoting: any;
  let owner: any;
  let addr1: any;
  let addr2: any;

  beforeEach(async function () {
    MovieVoting = await ethers.getContractFactory("MovieVoting");
    [owner, addr1, addr2] = await ethers.getSigners();
    movieVoting = await MovieVoting.deploy();
  });

  it("Ska sätta rätt ägare", async function () {
    expect(await movieVoting.owner()).to.equal(owner.address);
  });

  it("Ska skapa en omröstning", async function () {
    const movieList = ["Inception", "Titanic", "Interstellar"];
    await movieVoting.createPoll(movieList);
    const poll = await movieVoting.polls(1);
    expect(poll.creator).to.equal(owner.address);
  });

  it("Ska starta omröstningen", async function () {
    const movieList = ["Inception", "Titanic", "Interstellar"];
    await movieVoting.createPoll(movieList);
    await movieVoting.startVoting(1);
    const poll = await movieVoting.polls(1);
    expect(poll.state).to.equal(1); 
  });

  it("Ska låta användare rösta och avsluta om en film får 8 röster", async function () {
    const movieList = ["Inception", "Titanic", "Interstellar"];
    await movieVoting.createPoll(movieList);
    await movieVoting.startVoting(1);
  
   
    const signers = await ethers.getSigners();
  
    for (let i = 0; i < 8; i++) {
      await movieVoting.connect(signers[i]).vote(1, "Inception");
    }
  
    const poll = await movieVoting.polls(1);
    expect(poll.state).to.equal(2); 
    expect(poll.winner).to.equal("Inception");
  });

  it("Ska förhindra dubbelröstning", async function () {
    const movieList = ["Inception", "Titanic", "Interstellar"];
    await movieVoting.createPoll(movieList);
    await movieVoting.startVoting(1);

  
    await movieVoting.connect(addr1).vote(1, "Inception");

    await expect(
      movieVoting.connect(addr1).vote(1, "Inception")
    ).to.be.revertedWithCustomError(movieVoting, "AlreadyVoted");
  });
});