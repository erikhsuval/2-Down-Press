# 2 Down Press Flight Test Plan

## Core Features to Test

### User Management
- [ ] User account creation
- [ ] User profile management
- [ ] User persistence between app launches

### Group Management
- [ ] Creating groups (2-6 players)
- [ ] Editing group composition
- [ ] Group leader assignment
- [ ] Score entry permissions by group

### Bet Creation & Management
1. Individual Match Bets
   - [ ] Player selection
   - [ ] Amount entry
   - [ ] Press on 9 & 18 functionality
   - [ ] Winnings calculation

2. Four-Ball Match Bets
   - [ ] Team selection
   - [ ] Amount entry
   - [ ] Press on 9 & 18 functionality
   - [ ] Team winnings calculation

3. Alabama Bets
   - [ ] Team formation
   - [ ] Swing man assignment
   - [ ] Front/back nine amounts
   - [ ] Low ball amounts
   - [ ] Birdie amounts
   - [ ] Winnings calculation per team

4. Do-Da Bets
   - [ ] Pool vs. per-Do-Da setup
   - [ ] Amount entry
   - [ ] Winnings calculation

5. Skins Bets
   - [ ] Player selection
   - [ ] Amount entry
   - [ ] Skins calculation
   - [ ] Carryover functionality

6. Putting with Puff
   - [ ] Player selection
   - [ ] Amount entry
   - [ ] Real-time winnings update

### Scorecard Functionality
- [ ] Score entry
- [ ] Score validation
- [ ] Hole-by-hole navigation
- [ ] Front/back nine display
- [ ] Total score calculation
- [ ] Par relative scoring

### The Sheet
- [ ] Real-time updates
- [ ] Winnings calculation
- [ ] Player totals
- [ ] Bet breakdown
- [ ] Post/Unpost functionality

## Known Limitations
1. Maximum group size of 6 players
2. Maximum round duration of 6 hours
3. Scores must be whole numbers or 'X'
4. Players must be added before creating bets

## Edge Cases to Test
1. Network connectivity changes
2. App backgrounding/foregrounding
3. Simultaneous score entry from multiple groups
4. Large number of bets (stress testing)
5. Score modifications after posting
6. Group changes mid-round
7. Device rotation and different screen sizes

## Test Environment Setup
1. Multiple test devices (different iOS versions)
2. Multiple test accounts
3. Various group configurations
4. Different bet type combinations

## Success Criteria
1. All core features function as designed
2. Data persistence works reliably
3. No crashes or freezes
4. Accurate winnings calculations
5. Intuitive user experience
6. Responsive performance

## Bug Reporting Process
1. Screenshot of the issue
2. Steps to reproduce
3. Expected vs actual behavior
4. Device and iOS version
5. Network conditions
6. Any relevant user actions

## Test Completion Criteria
- All core features tested and verified
- No critical or high-priority bugs
- Performance metrics within acceptable range
- User feedback incorporated 