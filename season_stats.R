source('../compile.R')

# calculate averages
batting <- averages(read('batting_stats.txt'))
write(batting, 'batting_stats.txt')

# compile player season batting stats
batting_season <- compile(columns(batting), batting['batter'])
write(batting_season, 'batting_stats_season.txt')

# compile team-game batting stats
team_batting <- compile(columns(batting, FALSE), batting['game'])
write(team_batting, 'team_batting_stats.txt')

# compile team-season batting stats
team_batting_season <- compile(columns(team_batting, FALSE), list(rep(1, nrow(team_batting))))
team_batting_season[[1]] <- NULL
write(team_batting_season, 'team_batting_stats_season.txt')
