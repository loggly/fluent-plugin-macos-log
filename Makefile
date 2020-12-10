REPO_NAME=fluent-plugin-macos-log

bundle:
	bundle install

test: bundle
	bundle exec rake test

package: bundle
	rm -rf ${REPO_NAME}-*.gem
	bundle exec gem build ${REPO_NAME}.gemspec

release: package
	bundle exec gem push ${REPO_NAME}-*.gem