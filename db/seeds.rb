user = User.create(username: "kjoewill", email: "kjoewill@gmail.com", password: "password")
user.tweets <<  Tweet.create(content: "Kev's best tweet ever!")
user.tweets <<  Tweet.create(content: "Kev's second best tweet ever!")
user.tweets <<  Tweet.create(content: "Kev's third best tweet ever!")

user = User.create(username: "tdorwill", email: "tdorwill@gmail.com", password: "password")
user.tweets <<  Tweet.create(content: "Tanya's best tweet ever!")
user.tweets <<  Tweet.create(content: "Tanya's second best tweet ever!")
user.tweets <<  Tweet.create(content: "Tanya's third best tweet ever!")
