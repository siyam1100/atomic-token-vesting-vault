// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenVesting is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 start;
        uint256 cliff;
        uint256 duration;
    }

    IERC20 public immutable token;
    mapping(address => VestingSchedule) public schedules;

    event ScheduleCreated(address indexed beneficiary, uint256 amount);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function createSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _totalDuration,
        uint256 _amount
    ) external onlyOwner {
        require(schedules[_beneficiary].totalAmount == 0, "Schedule exists");
        
        schedules[_beneficiary] = VestingSchedule({
            totalAmount: _amount,
            releasedAmount: 0,
            start: _start,
            cliff: _start + _cliffDuration,
            duration: _totalDuration
        });

        token.safeTransferFrom(msg.sender, address(this), _amount);
        emit ScheduleCreated(_beneficiary, _amount);
    }

    function release() external nonReentrant {
        VestingSchedule storage schedule = schedules[msg.sender];
        require(schedule.totalAmount > 0, "No schedule found");
        require(block.timestamp >= schedule.cliff, "Cliff not reached");

        uint256 vested = _calculateVestedAmount(schedule);
        uint256 releasable = vested - schedule.releasedAmount;
        require(releasable > 0, "Nothing to release");

        schedule.releasedAmount += releasable;
        token.safeTransfer(msg.sender, releasable);

        emit TokensReleased(msg.sender, releasable);
    }

    function _calculateVestedAmount(VestingSchedule memory _schedule) internal view returns (uint256) {
        if (block.timestamp < _schedule.cliff) return 0;
        if (block.timestamp >= _schedule.start + _schedule.duration) return _schedule.totalAmount;
        
        return (_schedule.totalAmount * (block.timestamp - _schedule.start)) / _schedule.duration;
    }
}
