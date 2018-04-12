Hi there! This a CocoaPods plugin that **we, the community**, can use to plug the holes in React Native's CocoaPods
support.

CocoaPods allows you to add code to run at the end of the Podfile via a `post_install` hook. You probably already have
some custom code in there. This plugin allows all that code to be centralized and reasoned about in a single place per
React Native version.

## Why Does This Need To Exist?

React Native is a pragmatic project, it's great Facebook open sources it, but if you want to work with a flow they don't
use - the onus is on you to make sure it continues to work. Facebook have a big mono-repo, and so they don't need to use
CocoaPods, and they also use static compilation because they don't use Swift. Meaning if you want to use CocoaPods and
Swift, you're pretty far from their workflow.

In order to get it working for just your app you scour, like, a million issues on React Native (or go look at
[artsy/eigen][eigen]) to get it compiling on your setup. Again, not optimal.

This plugin _tries_ to fix this by centralizing the code needed to modify React Native. This means makes it easy to
update your versions of React Native, because you can update the gem at the same time.

## Installation

Lazy way (bad, but ok if 1 engineer):

    $ gem install cocoapods-fix-react-native

Correct way, edit your gemfile to be:

    gem "cocoapods"
    gem "cocoapods-fix-react-native"

Then remove any React Native related `post_install` code, and add this to the top level of your `Podfile`:

    plugin 'cocoapods-fix-react-native'

For the first time you do this, I'd recommend running `rm -rf Pods; bundle exec pod install`. After that you can
`bundle exec pod install` like normal.

## How do I Update This?

`bundle update cocoapods-fix-react-native`.

This project is auto-deployed after every merged PR, so it's should always be up-to-date.

## How Does This Work?

A CocoaPods plugin can register a `post_install` hook just like you can in your `Podfile`. This hook will first look at
what version of React Native is installed, and will then run a corresponding script to make changes to the environment.

## Contributing Back

You'll note that this repo has issues disabled, I'm not going to make the time to support questions and requests for
fixes to this. I have a lot of projects, and only so much time. However, I'm happy to handle the mainainance and upkeep
from code people submit. If you want a change, you'll need to do so yourself, so let's cover how you do that:

This project is very specific about what versions of React Native it supports, you can see them in the folder
[`lib/cocoapods-fix-react-native/versions/`][versions]:

```
~/dev/projects/react-native/cocoapods-fix-react-native master*
❯ tree lib/cocoapods-fix-react-native/versions/
lib/cocoapods-fix-react-native/versions/
└── 0_54_4.rb
```

There's likely more than just one by the time you read this, but if you want to use a version that isn't supported yet,
then you're going to want to copy the most recent into a new file. The files are named by converting dots to
underscores. E.g. `0.54.4` -> `0_54_4.rb`.

The scripts itself should be entirely self contained, so that it's easy to understand wthout learning the project.

The biggest change you'd need to make from the sort of code you can find inside the issues is that it needs to support
many different potential roots. So instead of just `Pods/React/*` - this plugin will also handle
`node_modules/react-native/*` and `../node_modules/react-native/*`. Basically, your dev repo, and your prod app.

This can be done by removing `'Pods/React'` from the path and wrapping it with a
`File.join(root, 'Path/InReactLib.js')`. You'll see this in the current scripts.

### Getting Setup To Improve

Clone this repo:

```
git clone https://github.com/orta/cocoapods-fix-react-native
cd cocoapods-fix-react-native
bundle install
```

You want to use a `:path` based gem in your project's Gemfile to point to the cloned repo. Make you to your App's
`Gemfile` something like this:

```ruby
gem 'cocoapods', '~> 1.4.0'
gem 'cocoapods-fix-react-native', path: "../../../../react-native/cocoapods-fix-react-native"
```

Then when you run `bundle exec pod install` in that project, it will use the the code from your cloned copy.

As `use_frameworks!` is more strict than static libraries, I'd recommend working on this project using a repo that has
frameworks.

[eigen]: https://github.com/artsy/eigen/
[versions]: https://github.com/orta/cocoapods-fix-react-native/tree/master/lib/cocoapods-fix-react-native/versions
