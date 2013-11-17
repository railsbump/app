.PHONY: test

console:
		pry -r ./app.rb

server:
		shotgun -o 0.0.0.0

test:
		cutest test/**/*.rb
