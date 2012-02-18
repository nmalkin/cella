About Cella
===========
Cella is a web-based application to help participants in the [Brown University](http://www.brown.edu/) [Housing Lottery](http://reslife.brown.edu/current_students/lottery/about.html) identify desired rooms conveniently and efficiently.

It is developed by [Nathan Malkin][] and [Sumner Warren][] and is a successor to _Domus_, a desktop application with similar goals, built by us and [Miya Schneider][] for [CS 32](http://cs.brown.edu/courses/csci0320.html).


Questions and Answers
---------------------

### What do I do?
Choose your lottery number (or an estimate for it) in the box at the top. Select the checkbox if you are a sophomore.

Then, choose the occupancy of the rooms you want to search for and the buildings to include, or exclude, in the search.

That's it!

### Did you know? You can...

* sort results by clicking on the column headers
* sort results by *multiple columns* by pressing down the *Shift* key when clicking on the header
* open multiple searches in multiple tabs
* click on the stars next to the results to add them to the "star tab"
* rearrange results in the star tab by dragging and dropping

### What does the probability bar mean?
The probability bar represents how likely we think it is that you will get this room based on the lottery number you entered. A full (green) bar means we are confident that you can get this room. An empty (red) bar means we're pretty confident that somebody will get the room before you.

But don't trust us (too much). The prediction is based on results from previous years, which aren't necessarily predictive of future results. Some rooms may have few old results, affecting the quality of the prediction.

The actual calculation of the probability is performed by fitting a [logistic model](http://en.wikipedia.org/wiki/Logistic_regression) to a room's previous lottery numbers. We thank Neil Thakral for this suggestion.

### Is that a mistake in your data?
There may be mistakes in the data. We got the information directly from the Lottery website and haven't verified it manually. Also, sometimes rooms change between years, making the past results less meaningful for calculating probability.

If you find an inaccuracy in the data, we would appreciate it if you reported it to us: just [send us an email][].

### Something's broken! What do I do?
To start over, click on "clear data" at the bottom of the page, then refresh the page.

If the problem appears consistently, please submit it to our [issue tracker][] or [send us an email][].

### I don't like the way ----- works. I think Cella should do -----.
We are always looking for feature suggestions. You can add your suggestion to our [issue tracker][] or [send us an email][].

### How does this work? Can I see the source code?
Sure! The project code [is on GitHub](https://github.com/nmalkin/cella). Feel free to peruse (and contribute!).



[issue tracker]: https://github.com/nmalkin/cella/issues
[send us an email]: http://www.google.com/recaptcha/mailhide/d?k=01bp7JyIti_rLGDhgxUfjeeA==&c=PzG-9KnaNLiH8dWk79HaWw==

[Nathan Malkin]: http://cs.brown.edu/people/nmalkin/
[Sumner Warren]: http://cs.brown.edu/people/jswarren/
[Miya Schneider]: http://cs.brown.edu/people/mmschnei/
