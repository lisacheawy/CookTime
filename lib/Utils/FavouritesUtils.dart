timeDifficulty(rTime, rDifficulty) {
  var time = rTime.contains("hour")
      ? '${rTime.split("hour")[0]}hr +'
      : '${rTime.split("minutes")[0]}min';
  switch (rDifficulty) {
    case ("Super easy"):
      var difficulty = 'Easy';
      return [time, difficulty];
    case ("Not too tricky"):
      var difficulty = 'Med';
      return [time, difficulty];
    case ("Showing off"):
      var difficulty = 'High';
      return [time, difficulty];
  }
}
