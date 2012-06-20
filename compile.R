options(digits=4)

read <- function(file, ...) {
    read.csv(file, comment.char='#', strip.white=TRUE, ...)
}

write <- function(df, file, ...) {
    write.csv(df, file, na='0', quote=FALSE, row.names=FALSE, ...)
}

join <- function(files) {
    df <- do.call(rbind, lapply(files, function(x) { cbind(season=dirname(x), read(x)) }))
    df[order(as.character(df$batter), as.character(df$season)),]
}

compile <- function(stats, by) {
    result <- aggregate(stats, by=by, FUN=sum)

    result$BA <- with(result, round(H / AB, 3))
    result$OBP <- with(result, round((H + BB)/(AB + BB + SF), 3))
    result$SLG <- with(result, round((H + X2B + X3B*2 + HR*3)/AB, 3))
    result$OPS <- with(result, round(OBP + SLG, 3))

    result <- cbind(result[1:length(by)], games=structure(unclass(table(by)), dimnames=NULL), result[-c(1:length(by))])
    if ('game' %in% names(by)) {
        names(result)[match('games', names(result))] <- 'batters'
    }
    if (sum(names(result) == 'games') == 2) {
        names(result)[match('games', names(result))] <- 'seasons'
    }
    result
}

reorder <- function(stats, columns) {
    stats[do.call(order, stats[columns]),]
}
