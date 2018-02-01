#Step 1 : import macros
#May 2015, Florent Le Néchet




# ---------------------------------------------------------------------------------
# ----------------            CREATE TABLE                   ----------------------
# ---------------------------------------------------------------------------------

createTable <- function(parametersValues,centreValues) {
  # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- #
  # This function reports a data.frame with three columns
  # X is the X-coordinate of the cell
  # Y is the Y-coordinate of the cell
  # Z is the Population within the cell
  # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- #
  # parameters for function createTable are : 
  # - a data.frame parametersValues containing 6 variables and 1 line: 
  # Xmin : minimum X coordinate for the table
  # Xmax : maximum X coordinate for the table
  # Ymin : minimum Y coordinate for the table
  # Ymax : maximum Y coordinate for the table
  # nu   : extent of the cell. Number of cells is (Xmax - Xmin) / nu   *  (Ymax - Ymin) / nu 
  # eta  : parameter used for the computation of the grid : the smaller it is the closest it is
  # from a real "Clark" distribution. During the double integration of the exponential, each grid-cell
  # of size nu is subdivided into mini-cells of size eta.
  # therefore eta should be small than nu, around a tenth of its value.
  # - a data.frame centreValues containing 4 variables and as many lines as centers: 
  # X0 : X coordinate of the center
  # Y0 : Y coordinate of the center
  # A  : A parameter (Clark distribution : density = A exp(-b r))
  # b  : b parameter (Clark distribution : density = A exp(-b r)))
  # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- # -- #
  
  Xmin = parametersValues$Xmin[1]
  Ymin = parametersValues$Ymin[1]
  Xmax = parametersValues$Xmax[1]
  Ymax = parametersValues$Ymax[1]
  nombreCentres = nrow(centresValues)
  XXX = NULL
  YYY = NULL
  PPP = NULL
  i = 1
  xt = Xmin
  while (xt < Xmax) {
    yt = Ymin
    while (yt < Ymax) {
      XXX[i] = xt 
      YYY[i] = yt
      j = 1
      PPP[i] = 0
      while (j <= nombreCentres) {
        PPP[i] = PPP[i] + reportPopulationCarre(xt,xt + parametersValues$nu[1],
                                                yt,yt + parametersValues$nu[1],
                                                centresValues$X0[j],
                                                centresValues$Y0[j],
                                                centresValues$A[j],
                                                centresValues$b[j],
                                                parametersValues$eta[1])
        j = j + 1
      }
      i = i + 1  
      yt = yt + parametersValues$nu[1]
    }
    xt = xt +  parametersValues$nu[1]
  }
  dataFin = data.frame(cbind(XXX,YYY,PPP))
  names(dataFin) = c("X","Y","Z")
  #dataFin[dataFin$Z<0,] = 0
  dataFin
}

# ---------------------------------------------------------------------------------
# ----------------         REPORT POPULATION CARREE         ----------------------
# ---------------------------------------------------------------------------------


reportPopulationCarre <- function(x1,x2,y1,y2,X0,Y0,A,b,eta) {
  #compute the population of a Clark distribution of parameters A, b and center X0, Y0
  PopTemp = 0
  xx = x1
  while (xx + eta <= x2) {
    yy = y1
    while(yy + eta <= y2) {
      Rtemp = sqrt((X0 - xx - (1/2) * eta)^2+(Y0 - yy - (1/2) * eta)^2)
      PopTemp = PopTemp + eta ^ 2 * A * exp(- b * Rtemp)
      yy = yy + eta
      #         print(yy)
      #        flush.console()  # force the output
    }
    xx = xx + eta
  }
  PopTemp  
}


# ---------------------------------------------------------------------------------
# ----------------           DRAW IN TWO  DIMENSIONS         ----------------------
# ---------------------------------------------------------------------------------

afficher2d <- function(dataFin) {
  colorPalette <- terrain.colors(nrow(dataFin), alpha = 1)
  dataFin <- dataFin[order(dataFin$Z,decreasing = TRUE),]
  plot(dataFin$X,dataFin$Y,col = colorPalette, pch = 19, cex = 1)
}


# ---------------------------------------------------------------------------------
# ----------------           DRAW IN THREE   DIMENSIONS      ----------------------
# ---------------------------------------------------------------------------------


library(scatterplot3d)
afficher3d <- function(dataFin) {
  scatterplot3d(dataFin$X,dataFin$Y,dataFin$Z, main="3D Scatterplot", type = "h",highlight.3d=TRUE, pch = 19, xlab = "", ylab = "", zlab = "density", cex.symbols=0.1)}

# ---------------------------------------------------------------------------------
# ----------------      COMPUTE URBAN FORM INDICATORS        ----------------------
# ---------------------------------------------------------------------------------



reportPopulation <- function (table, cutoffdensity) {
  
  table <- subset(table, Z > cutoffdensity)
  sum(table$Z)  
}

reportDensity <- function (table, cutoffdensity) {
  cellExtent <- 0.25 #pas générique
  table <- subset(table, Z > cutoffdensity)
  pop = sum(table$Z)
  Ncellules = nrow(table)
  area = Ncellules * cellExtent^2
  density = pop / area
  density
}


reportDistance <- function (table, cutoffdensity) {

  #### table is made of three columns : X, Y, Z containing coordinates and 
  # Population in the corresponding cell
  #### unit is the unit of distance of the coordinates
  #### cutoffdensity is the cut off density used for the computation of all indicators
  table = subset(table, Z > cutoffdensity)
  table = table[order(-table$Z),]
  xx = table$X 
  yy = table$Y 
  zz = table$Z
  toadd = 0
  aa = 0
  bb = 0
  distance = 0
  listDistance = NULL
  listPop = NULL
  n = nrow(data.frame(zz))
  print(n)
  flush.console()
  i = 1
  compteur = 0
  while (i <= n) {
    j = 1
    toadd = 0
    while (j < i) {
      aa = xx[i]
      bb = yy[i]
      toadd = toadd + sqrt((aa - xx[j])^2+(bb - yy[j])^2) * zz[j]
      j = j + 1
    }
    distance = distance + toadd * zz[i]
    listDistance = c(listDistance, distance)
    listPop = c(listPop, sum(zz[1:i]))
    compteur = compteur + 1
    if ((compteur / 1000) == floor(compteur / 1000)) {
      print(compteur * (compteur - 1) / (n * (n - 1)) * 100)
      flush.console() } # force the output
    i = i + 1
  }
  
  resultat = 2 * distance / sum(zz)^2
  #cbind(listDistance, listPop)
  resultat
}




reportEntropy <- function (table, cutoffdensity) {
  table = subset(table, Z > cutoffdensity)
  xx = table$X
  yy = table$Y
  zz = table$Z
  zT = sum(zz)
  toadd = 0
  n = nrow(data.frame(zz))
  for (i in 1:n) {
    toadd = toadd + zz[i] / zT * log(zz[i] / zT)
  }
  -1 * toadd / log(n)
}

reportRankSize <- function (table, cutoffdensity) {
  table = subset(table, Z > cutoffdensity)
  xx = table$X
  yy = table$Y
  zz = table$Z
  n = nrow(data.frame(zz[zz>0]))
  rang = log(1:n)
  taille = log(zz[zz>0][order(-zz[zz>0])])
  
  
  
  lmRT <- lm(taille~rang)
  RT = -summary(lmRT)$coeff[2]
  K = exp(summary(lmRT)$coeff[1])
  Rsquared = summary(lmRT)$r.squared
  
  resultat = cbind(RT,K,Rsquared)
  
  resultat
  
}





reportMoran <- function (table, cutoffdensity) {
  table = subset(table, Z > cutoffdensity)
  xx = table$X
  yy = table$Y
  zz = table$Z
  zT = as.numeric(sum(zz))
  n = nrow(data.frame(zz))
  toadd1 = 0
  toadd2 = 0
  j = 2
  #i = 1
  for (i in 1:n) {
    j = i + 1
    while (j <= n) {
      dij = sqrt((xx[i]-xx[j])^2+(yy[i]-yy[j])^2)
      toadd1 = toadd1 + (zz[i] - zT / n) * (zz[j] - zT / n) / dij
      toadd2 = toadd2 + 1 / dij
      j = j + 1
    }
  }
  toadd3 = 0
  for (i in 1:n) {
    toadd3 = toadd3 + (zz[i] - zT / n)^2
  }
  n * toadd1 / (2 * toadd2 * toadd3)
}


#Step 2 : create "cities" on grid

# Exemple : création d'un centre
centresValues1 = c(6.25,6.25,20000,0.7)
centresValues = data.frame(t(centresValues1))
#centresValues = data.frame(t(cbind(centresValues1,centresValues2)))
names(centresValues) = c("X0","Y0","A","b")

parametersValues = data.frame(t(c(0,12.5,0,12.5,0.25,0.05)))
names(parametersValues) = c("Xmin","Xmax","Ymin","Ymax","nu","eta")
grid1 = createTable(parametersValues,centresValues)

#Génération de plusieurs centres y compris des "puits"
N = floor(runif(1,1,25))
tempTab = NULL
i = 1
for (i in 1:N) {
  x = c(runif(1,0,12.5),runif(1,0,12.5),runif(1,-1000,3000),runif(1,0,1))
tempTab = cbind(tempTab,x)
}
centresValues = data.frame(t(tempTab))
names(centresValues) = c("X0","Y0","A","b")

parametersValues = data.frame(t(c(0,12.5,0,12.5,0.25,0.005)))
names(parametersValues) = c("Xmin","Xmax","Ymin","Ymax","nu","eta")
grid2 = createTable(parametersValues,centresValues)



afficher2d(grid2)

grid1 = grid2
#Step 3 : compute indicators
#Density threshold 200 correspond to a minimum density of 3200 inh. / km2
reportPopulation(grid1,0)
reportPopulation(grid1,200)
plot(grid1$Z)
reportDensity(grid1,0)
reportDensity(grid1,200)
reportDistance(grid1,0)
reportDistance(grid1,200)
reportEntropy(grid1,0)
reportEntropy(grid1,200)
reportMoran(grid1,0)
reportMoran(grid1,200)
reportRankSize(grid1,0)
reportRankSize(grid1,200)

#Step 4: assess the city-iness of the grid