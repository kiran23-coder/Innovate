// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Innovate Project Smart Contract
 * @dev A simple decentralized platform to propose, fund, and complete innovation projects.
 */

contract Project {
    // Struct to represent a project proposal
    struct Proposal {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 fundingGoal;
        uint256 fundsRaised;
        bool isCompleted;
    }

    uint256 public projectCount;
    mapping(uint256 => Proposal) public projects;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event ProjectCreated(uint256 indexed id, string title, address indexed creator);
    event Funded(uint256 indexed id, address indexed funder, uint256 amount);
    event ProjectCompleted(uint256 indexed id, string title);

    /**
     * @dev Create a new project proposal
     * @param _title Title of the project
     * @param _description Brief description of the project
     * @param _fundingGoal Funding goal in wei
     */
    function createProject(
        string memory _title,
        string memory _description,
        uint256 _fundingGoal
    ) external {
        require(_fundingGoal > 0, "Funding goal must be greater than 0");

        projectCount++;
        projects[projectCount] = Proposal(
            projectCount,
            msg.sender,
            _title,
            _description,
            _fundingGoal,
            0,
            false
        );

        emit ProjectCreated(projectCount, _title, msg.sender);
    }

    /**
     * @dev Fund an existing project
     * @param _projectId ID of the project to fund
     */
    function fundProject(uint256 _projectId) external payable {
        Proposal storage project = projects[_projectId];
        require(_projectId > 0 && _projectId <= projectCount, "Invalid project ID");
        require(!project.isCompleted, "Project already completed");
        require(msg.value > 0, "Funding amount must be greater than zero");

        project.fundsRaised += msg.value;
        contributions[_projectId][msg.sender] += msg.value;

        emit Funded(_projectId, msg.sender, msg.value);
    }

    /**
     * @dev Mark a project as completed if funding goal reached
     * @param _projectId ID of the project to mark as completed
     */
    function completeProject(uint256 _projectId) external {
        Proposal storage project = projects[_projectId];
        require(msg.sender == project.creator, "Only creator can mark as completed");
        require(!project.isCompleted, "Project already completed");
        require(project.fundsRaised >= project.fundingGoal, "Funding goal not reached");

        project.isCompleted = true;
        payable(project.creator).transfer(project.fundsRaised);

        emit ProjectCompleted(_projectId, project.title);
    }
}
