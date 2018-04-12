printf <- function(...) cat(sprintf(...))

swapRooms = function (pop, noOfCourses, rooms, noOfRooms) {
  choice1 = rooms[sample(1:noOfRooms, 1, replace = T)]
  choice2 = rooms[sample(1:noOfRooms, 1, replace = T)]
  for (i in seq(1,length(pop),8)) {
    if (pop[i+1]==choice1) {
      pop[i+1] = choice2
    }
    else if (pop[i+1]==choice2) {
      pop[i+1] = choice1
    }
  }
  pop
}

swapTimeSlot = function (pop, noOfCourses, timeSlots, noOftimeSlots) {
  choice1 = timeSlots[sample(1:noOftimeSlots, 1, replace = T)]
  choice2 = timeSlots[sample(1:noOftimeSlots, 1, replace = T)]
  for (i in seq(1,length(pop),8)) {
    if (pop[i]==choice1) {
      pop[i] = choice2
    }
    else if (pop[i]==choice2) {
      pop[i] = choice1
    }
  }
  pop
}

changeTimeSlot = function (pop, noOfCourses, timeSlots, noOfTimeSlots) {
  courseChoice = sample(1:noOfCourses, 1, replace = T)
  timeSlotChoice = timeSlots[sample(1:noOfTimeSlots, 1, replace = T)]
  
  pop[1+(courseChoice-1)*8] = timeSlotChoice
  
  pop
}

mutate = function (pop, noOfCourses, timeSlots, rooms, noOfTimeSlots, noOfRooms) {
  courseChoice = sample(1:noOfCourses, 1, replace = T)
  timeSlotChoice = timeSlots[sample(1:noOfTimeSlots, 1, replace = T)]
  roomChoice = rooms[sample(1:noOfRooms, 1, replace = T)]
  
  pop[1+(courseChoice-1)*8] = timeSlotChoice
  pop[2+(courseChoice-1)*8] = roomChoice
  
  pop
}

fitness = function (pop, popSize, noOfCourses, rooms, timeSlots) {
  fit = c()
  for (i in 1:popSize) {
    fitnessVal = 0
    currentChromosome = (i-1)*noOfCourses*8
    for (j in seq(1,noOfCourses*8, 8)) {
      allocatedTimeSlot = pop[currentChromosome + j]
      allocatedRoom = pop[currentChromosome + j+1]
      allocatedProfessor = pop[currentChromosome + j+3]
      
      for (k in 1:2) {
        if (allocatedRoom == pop[currentChromosome + j+5 + k]) {
          requestedRoom = 1
          break
        }
        requestedRoom = 0
      }
      
      for (k in 1:2) {
        if (allocatedTimeSlot == pop[currentChromosome + j+3 + k]) {
          requestedTimeSlot = 1
          break
        }
        requestedTimeSlot = 0
      }
      
      RoomTimeSlotClash = 2
      RoomProfessorClash = 2
      
      if (j+8 <= noOfCourses*8) {
        for (k in seq(j+8, noOfCourses*8, by = 8)) {
          if (allocatedTimeSlot == pop[currentChromosome + k]) {
            if (allocatedRoom == pop[currentChromosome + k+1])
              RoomTimeSlotClash = 0
            if (allocatedProfessor == pop[currentChromosome + k+3])
              RoomProfessorClash = 0
          }
        }
      }
      
      fitnessVal = fitnessVal + requestedRoom + requestedTimeSlot + RoomProfessorClash + RoomTimeSlotClash
    }
    fit = c(fit, fitnessVal)
  }
  fit
}

schedule = function (courses, popSize, timeSlots, rooms, maxIter) {
  population = c()
  fit = c()
  
  noOfTimeSlots = length(timeSlots)
  noOfRooms = length(rooms)
  noOfCourses = dim(courses)[1]
  courses = as.vector(t(courses))
  
  for (i in 1:popSize) {
    for (j in 1:noOfCourses) {
      population = c(population, timeSlots[sample(1:noOfTimeSlots, 1, replace=T)])
      population = c(population, rooms[sample(1:noOfRooms, 1, replace=T)])
      #course
      population = c(population, courses[1+6*(j-1)])
      #professor
      population = c(population, courses[2+6*(j-1)])
      #times
      population = c(population, courses[5+6*(j-1)], courses[6+6*(j-1)])
      #rooms
      population = c(population, courses[3+6*(j-1)], courses[4+6*(j-1)])
    }
  }
  
  fit = fitness(population, popSize, noOfCourses, rooms, timeSlots)
  
  genNo = 0
  
  while (genNo < maxIter) {
    printf('Generation no : %d\n', genNo)
    newPopulation = c()
    toBeRetained = sort(fit, decreasing = TRUE)[1:(popSize/10)]
    
    maxIndices = c()
    tempFit = fit
    tempPop = c()
    
    for (j in 1:(popSize/10)) {
      maxIndices = c(maxIndices, match(toBeRetained[j], tempFit))
      tempFit[maxIndices[j]] = 0
      tempPop = c(tempPop, population[(1+(maxIndices[j]-1)*8*noOfCourses):((maxIndices[j]-1)*8*noOfCourses + 8*noOfCourses)])
    }
    
    for (j in 1:popSize) {
      choice1 = sample(1:popSize, 1, replace=T)
      choice2 = sample(1:popSize, 1, replace=T)
      
      if (fit[choice1] > fit[choice2]) {
        winner = choice1
      }
      else {
        winner = choice2
      }
      
      winner = population[(1+(winner-1)*noOfCourses*8):((winner-1)*8*noOfCourses + 8*noOfCourses)]
      
      method = runif(1)
      
      if (method < 0.15) {
        child = mutate(winner, noOfCourses, timeSlots, rooms, noOfTimeSlots, noOfRooms)
      }
      else {
        method = sample(1:3, 1, replace=T)
        if (method==1) {
          child = swapRooms(winner, noOfCourses, rooms, noOfRooms)
        }
        else if (method==2) {
          child = swapTimeSlot(winner, noOfCourses, timeSlots, noOfTimeSlots)
        }
        else {
          child = changeTimeSlot(winner, noOfCourses, timeSlots, noOfTimeSlots)
        }
      }
      
      if (fitness(child, 1, noOfCourses, rooms, timeSlots) > fitness(winner, 1, noOfCourses, rooms, timeSlots)) {
        newPopulation = c(newPopulation, child)
      }
      else {
        newPopulation = c(newPopulation, winner)
      }
      
    }
    population = newPopulation
    fit = fitness(population, popSize, noOfCourses, rooms, timeSlots)
    genNo = genNo + 1
  }
  
  winner = which.max(fit)
  population[(1+(winner-1)*noOfCourses*8):((winner-1)*8*noOfCourses + 8*noOfCourses)]
}

formatted = function (s) {
  l = length(s)
  out = ''
  if (l%%8!=0) {
    out = "error"
    exit
  }
  l = l/8
  for (i in 1:l) {
    temp = (i-1)*8
    out = cat(paste(out, '\n', s[temp+1], s[temp+2], s[temp+3], s[temp+4], s[temp+5], s[temp+6], s[temp+7], s[temp+8]))
  }
  #print(s)
  out  
}

main = function () {
  # noOfTimeSlots = readline("Enter the number of time slots : ")
  # noOfTimeSlots = strtoi(noOfTimeSlots)
  # timeSlots = c()
  # printf ("Enter the time slots")
  # for (temp in 1:noOfTimeSlots) {
  #   timeSlots = c(timeSlots, readline())
  # }
  # 
  # noOfRooms = readline("Enter the number of rooms : ")
  # noOfRooms = strtoi(noOfRooms)
  # rooms = c()
  # printf ("Enter the rooms")
  # for (temp in 1:noOfRooms) {
  #   rooms = c(rooms, readline())
  # }

  library(tcltk)
  
  timeSlots = c(readLines(tk_choose.files(caption = "Time Slots")))
  #timeSlots = c(readLines("C:/Users/sanja/Desktop/slots.csv"))
  
  rooms = c(readLines((tk_choose.files(caption = "Rooms"))))
  #rooms = c(readLines("C:/Users/sanja/Desktop/rooms.csv"))
  
  initialData = read.csv(tk_choose.files(caption = "Initial Data"))
  #initialData = read.csv("C:/Users/sanja/Desktop/initialData.csv")
  
  #s = schedule(initialData, 100, timeSlots, rooms, 1000)
  s = schedule(initialData, 100, timeSlots, rooms, 1000)
  #print (formatted(s))
  output = formatted(s)
}

main()