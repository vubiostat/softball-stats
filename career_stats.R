source('compile.R')

batting <- join(system('ls */batting_stats.txt', TRUE))
write(batting, 'batting_stats.txt')

batting_seasons <- join(system('ls */batting_stats_season.txt', TRUE))
write(batting_seasons, 'batting_stats_season.txt')

batting_career <- compile(batting_seasons[,-c(1:2,17:20)], batting_seasons['batter'])
batting_career <- batting_career[order(as.character(batting_career$batter)),]
write(batting_career, 'batting_stats_career.txt')

team_batting <- join(system('ls */team_batting_stats.txt', TRUE))
write(reorder(team_batting, c('season', 'game')), 'team_batting_stats.txt')

team_batting_seasons <- join(system('ls */team_batting_stats_season.txt', TRUE))
write(reorder(team_batting_seasons, 'season'), 'team_batting_stats_season.txt')
