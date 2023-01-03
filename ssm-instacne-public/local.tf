locals {
  instance = {
    ports_in = [
      22,
      443,
      80
    ]
    ports_out = [
      0
    ]
  }
}