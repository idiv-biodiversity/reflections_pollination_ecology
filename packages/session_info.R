# /////////////////////////////////////////////////////////////////////////
# (OPTIONAL) Store R packages information.
# This shows how the files: "/packages/packages.csv" & 
# "packages/sessionInfo.txt" were created
# This script was run after executing R/01_packages.R 
# (so after needed packages were attached)
# /////////////////////////////////////////////////////////////////////////


# Store R session information in "/packages/sessionInfo.txt'
sink(file = "packages/sessionInfo.txt")
sessionInfo()
sink()


# Store R package information in "/packages/packages.csv"
# Store as table with three columns: package name, version, and type.
r_session <- sessionInfo()

pk   <- c(r_session$basePkgs,
          names(r_session$otherPkgs),
          names(r_session$loadedOnly))
ver  <- sapply(pk, getNamespaceVersion)
type <- rep(x = c("base_package", 
                  "attached_package", 
                  "loaded_not_attached"),
            times = c(length(r_session$basePkgs),
                      length(r_session$otherPkgs),
                      length(r_session$loadedOnly)))

df <- data.frame(package = pk, 
                 version = ver,
                 type = type)

write.csv(df, file = "packages/packages.csv", row.names = FALSE)
