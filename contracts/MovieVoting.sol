pragma solidity 0.8.24;

contract MovieVoting {
   
    address public owner;

    enum VotingState { notStarted, Ongoing, Finished }

   
    struct Movie {
        string title; 
        uint voteCount;
    }

 
    struct Poll {
        address creator; 
        string winner; 
        VotingState state; 
        mapping(address => bool) hasVoted; 
        Movie[] movies;
    }

  
    mapping(uint => Poll) public polls;
    uint public pollCount;

 
    error AlreadyVoted();
    error InvalidState(VotingState requiredState);
    error PollNotFound();
    error InvalidMovie();

    event PollCreated(uint pollId, address creator, string[] movies);
    event VoteCast(uint pollId, address voter, string movie);
    event VotingStarted(uint pollId);
    event VotingEnded(uint pollId, string winner); 

    constructor() {
        owner = msg.sender;
    }

    modifier inState(uint _pollId, VotingState _state) {
        if(polls[_pollId].state != _state) {
            revert InvalidState(_state);
        }
        _;
    }

    modifier onlyCreator(uint _pollId) {
        require(msg.sender == polls[_pollId].creator, "Only the poll creator can call this");
        _;
    }

    // Funktion för att skapa en ny omröstning
    function createPoll(string[] memory _movieTitles) public {
        require(_movieTitles.length > 0, "At least one movie required");
        uint previousPollCount = pollCount;
        pollCount++; 

        
        assert(pollCount == previousPollCount + 1);

        Poll storage newPoll = polls[pollCount]; 
        newPoll.creator = msg.sender; 
        newPoll.state = VotingState.notStarted; 

       
        for (uint i = 0; i < _movieTitles.length; i++) {
            newPoll.movies.push(Movie({title: _movieTitles[i], voteCount: 0}));
        }

        emit PollCreated(pollCount, msg.sender, _movieTitles); 
    }

    // Funktion för att starta en omröstning manuellt
    function startVoting(uint _pollId) public onlyCreator(_pollId) inState(_pollId, VotingState.notStarted) {
        polls[_pollId].state = VotingState.Ongoing; 
        emit VotingStarted(_pollId); 
    }

    // Funktion för att lägga en röst på en film i en pågående omröstning 
    function vote(uint _pollId, string memory _movieTitle) public inState(_pollId, VotingState.Ongoing) {
        Poll storage poll = polls[_pollId];

        if (poll.hasVoted[msg.sender]) revert AlreadyVoted(); 

        Movie[] storage movies = poll.movies; // Använd storage för att spara gas
        bool found = false;

       
        for (uint i = 0; i < movies.length; i++) {
            if (keccak256(bytes(movies[i].title)) == keccak256(bytes(_movieTitle))) {
                movies[i].voteCount++; 
                found = true;

                // Om filmen får 8 röster avslutas omröstningen
                if (movies[i].voteCount == 8) {
                    poll.state = VotingState.Finished; 
                    poll.winner = movies[i].title; 
                    emit VotingEnded(_pollId, poll.winner); 
                }

                break;
            }
        }

        if (!found) revert InvalidMovie();
        poll.hasVoted[msg.sender] = true; 

        emit VoteCast(_pollId, msg.sender, _movieTitle); 
    }

   
    function getMovies(uint _pollId) public view returns (Movie[] memory) {
        return polls[_pollId].movies; 
    }

  
    fallback() external payable {}

    
    receive() external payable {}
}