source('../compile.R')

batting <- read('batting_stats.txt')

# compile player season batting stats
batting_season <- compile(batting[,-c(1:2,16:19)], batting['batter'])
write(batting_season, 'batting_stats_season.txt')

# compile team-game batting stats
team_batting <- compile(batting[,-c(1:3,16:19)], batting['game'])
write(team_batting, 'team_batting_stats.txt')

# compile team-season batting stats
team_batting_season <- compile(team_batting[,-c(1,15:18)], list(rep(1, nrow(team_batting))))
team_batting_season[[1]] <- NULL
write(team_batting_season, 'team_batting_stats_season.txt')
