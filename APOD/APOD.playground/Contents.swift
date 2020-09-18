import Foundation



let apodURL = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!
let session = URLSession(configuration: .default)

session.dataTask(with: apodURL) { (data, response, error) in
	guard let data = data else { return }
	
	guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else { return }
	
	print(json)
	
	if let dateString = json["date"] {
		print(dateString)
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withFullDate
		print(formatter.date(from: dateString))
	}
}.resume()

func parseAPODHTML(_ html: String) {
	let boldPattern = try? NSRegularExpression(pattern: #"(?<=<b>).*(?=<\/b>)"#)
	let imageLinkPattern = try? NSRegularExpression(pattern: #"(?<=href=('|"))image\/.*\.(png|jpg)(?=('|"))"#)
	let imageCreditLabelPattern = try? NSRegularExpression(pattern: #"(?<=<b>)[^<]*?Image Credit[^<]*?(?=<\/b>)"#)
	let range = NSRange(location: 0, length: html.count)
	
	
	let titleRange = boldPattern!.rangeOfFirstMatch(in: html, range: range)
	let title = html[Range(titleRange, in: html)!].trimmingCharacters(in: .whitespaces)
	
	let imageRange = imageLinkPattern!.rangeOfFirstMatch(in: html, range: range)
	let imageLink = "https://apod.nasa.gov/apod/" + html[Range(imageRange, in: html)!].trimmingCharacters(in: .whitespaces)
	
	let imageURL = URL(string: imageLink)!
	
	var explanation = ""
	var imageCreditLabel = ""
	var imageCredit = ""
	
	for line in html.components(separatedBy: "<p>") {
		let paragraph = line.replacingOccurrences(of: #"\s"#, with: " ", options: .regularExpression)
		if paragraph.contains("<b> Explanation: </b>") {
			explanation = paragraph.replacingOccurrences(of: "<b> Explanation: </b>", with: "").replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
		} else if paragraph.contains("Image Credit") {
			for part in paragraph.components(separatedBy: "<center>") {
				if part.contains("Image Credit") {
					if let creditLabelRange = imageCreditLabelPattern?.rangeOfFirstMatch(in: part, range: NSRange(location: 0, length: part.count)) {
						let stringRange = Range(creditLabelRange, in: part)! as Range<String.Index>
						
						imageCreditLabel = part[stringRange].trimmingCharacters(in: .whitespaces)
					}
					imageCredit = part.replacingOccurrences(of: #"<b>.*Image Credit.*<\/b>"#, with: "", options: .regularExpression).replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
				}
			}
		}
	}
	
	let dateString = html.components(separatedBy: "<p>")[2].replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: #"<br>.*"#, with: "", options: .regularExpression)
	
	print(dateString, imageCreditLabel, imageCredit)
}

let html = """
<!DOCTYPE html>
<html><head>
<title>Astronomy Picture of the Day
</title>
<!-- gsfc meta tags -->
<meta name="orgcode" content="661">
<meta name="rno" content="phillip.a.newman">
<meta name="content-owner" content="Jerry.T.Bonnell.1">
<meta name="webmaster" content="Stephen.F.Fantasia.1">
<meta name="description" content="A different astronomy and space science
related image is featured each day, along with a brief explanation.">
<!-- -->
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="keywords" content="Earth, diurnal motion, sky">
<!-- -->
<script async="" src="https://www.google-analytics.com/analytics.js"></script><script id="_fed_an_ua_tag" src="//dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=NASA">
</script>

</head>

<body bgcolor="#F4F4FF" text="#000000" link="#0000FF" vlink="#7F0F9F" alink="#FF0000">

<center>
<h1> Astronomy Picture of the Day </h1>
<p>

<a href="archivepix.html">Discover the cosmos!</a>
Each day a different image or photograph of our fascinating universe is
featured, along with a brief explanation written by a professional astronomer.
</p><p>

2020 July 1
<br>
<iframe width="960" height="540" src="https://www.youtube.com/embed/re3oEKX6Fks?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</p></center>

<center>
<b> Our Rotating Earth </b> <br>
<b> Video Credit &amp; Copyright: </b>
<a href="mailto: sklep @at@ artuniverse .dot. pl">Bartosz</a>
<a href="https://www.youtube.com/c/BartoszWojczy%C5%84ski/about">Wojczyński</a>
</center> <p>

<b> Explanation: </b>
Has your world ever turned upside-down?

It would happen every day if you stay fixed to the stars.

Most time-lapse videos of the night sky show the
<a href="ap140526.html">stars and sky moving above a steady Earth</a>.

Here, however, the camera has been forced to rotate so that the
<a href="ap110601.html">stars remain fixed</a>, and the Earth rotates around them.

<a href="https://www.youtube.com/embed/re3oEKX6Fks">The movie</a>,
with each hour is compressed to a second,
dramatically demonstrates the daily rotation of the Earth, called
<a href="https://en.wikipedia.org/wiki/Diurnal_motion">diurnal motion</a>.

<a href="https://www.youtube.com/watch?v=DmwaUBY53YQ">The video</a>
begins by showing an open field in
<a href="https://en.wikipedia.org/wiki/Namibia">Namibia</a>,
<a href="https://en.wikipedia.org/wiki/Africa">Africa</a>,
on a clear day, last year.

Shadows shift as the
<a href="ap190520.html">Earth turns</a>, the
<a href="ap090624.html">shadow of the Earth rises</a> into the sky, the
<a href="ap120207.html">Belt of Venus</a> momentarily appears,
and then day turns into night.

The majestic band of our
<a href="https://imagine.gsfc.nasa.gov/science/objects/milkyway1.html">Milky Way Galaxy</a> stretches across the night sky,
while sunlight-reflecting, Earth-orbiting
<a href="https://www.heavens-above.com/">satellites zoom by</a>.

In the night sky, you can even spot the
<a href="ap180428.html">Large and Small Magellanic Clouds</a>.

The video shows a sky visible from Earth's
<a href="https://en.wikipedia.org/wiki/Southern_Hemisphere">Southern Hemisphere</a>,
but a similar video could be made for every middle latitude on
<a href="https://solarsystem.nasa.gov/planets/earth/overview/">our blue planet</a>.


</p><p> </p><center>
<b> Almost Hyperspace: </b>
<a href="https://apod.nasa.gov/apod/random_apod.html">Random APOD Generator</a> <br>
<b> Tomorrow's picture: </b>open space

<p> </p><hr>
<a href="ap200630.html">&lt;</a>
| <a href="archivepix.html">Archive</a>
| <a href="lib/apsubmit2015.html">Submissions</a>
| <a href="lib/aptree.html">Index</a>
| <a href="https://antwrp.gsfc.nasa.gov/cgi-bin/apod/apod_search">Search</a>
| <a href="calendar/allyears.html">Calendar</a>
| <a href="/apod.rss">RSS</a>
| <a href="lib/edlinks.html">Education</a>
| <a href="lib/about_apod.html">About APOD</a>
| <a href="http://asterisk.apod.com/discuss_apod.php?date=200701">Discuss</a>
| <a href="ap200702.html">&gt;</a>

<hr><p>
<b> Authors &amp; editors: </b>
<a href="http://www.phy.mtu.edu/faculty/Nemiroff.html">Robert Nemiroff</a>
(<a href="http://www.phy.mtu.edu/">MTU</a>) &amp;
<a href="https://antwrp.gsfc.nasa.gov/htmltest/jbonnell/www/bonnell.html">Jerry Bonnell</a> (<a href="http://www.astro.umd.edu/">UMCP</a>)<br>
<b>NASA Official: </b> Phillip Newman
<a href="lib/about_apod.html#srapply">Specific rights apply</a>.<br>
<a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">NASA Web
Privacy Policy and Important Notices</a><br>
<b>A service of:</b>
<a href="https://astrophysics.gsfc.nasa.gov/">ASD</a> at
<a href="https://www.nasa.gov/">NASA</a> /
<a href="https://www.nasa.gov/centers/goddard/">GSFC</a>
<br><b>&amp;</b> <a href="http://www.mtu.edu/">Michigan Tech. U.</a><br>
</p></center>



</body></html>
<head>
<title>Astronomy Picture of the Day
</title>
<!-- gsfc meta tags -->
<meta name="orgcode" content="661">
<meta name="rno" content="phillip.a.newman">
<meta name="content-owner" content="Jerry.T.Bonnell.1">
<meta name="webmaster" content="Stephen.F.Fantasia.1">
<meta name="description" content="A different astronomy and space science
related image is featured each day, along with a brief explanation.">
<!-- -->
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="keywords" content="Earth, diurnal motion, sky">
<!-- -->
<script async="" src="https://www.google-analytics.com/analytics.js"></script><script id="_fed_an_ua_tag" src="//dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=NASA">
</script>

</head>
<body bgcolor="#F4F4FF" text="#000000" link="#0000FF" vlink="#7F0F9F" alink="#FF0000">

<center>
<h1> Astronomy Picture of the Day </h1>
<p>

<a href="archivepix.html">Discover the cosmos!</a>
Each day a different image or photograph of our fascinating universe is
featured, along with a brief explanation written by a professional astronomer.
</p><p>

2020 July 1
<br>
<iframe width="960" height="540" src="https://www.youtube.com/embed/re3oEKX6Fks?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</p></center>

<center>
<b> Our Rotating Earth </b> <br>
<b> Video Credit &amp; Copyright: </b>
<a href="mailto: sklep @at@ artuniverse .dot. pl">Bartosz</a>
<a href="https://www.youtube.com/c/BartoszWojczy%C5%84ski/about">Wojczyński</a>
</center> <p>

<b> Explanation: </b>
Has your world ever turned upside-down?

It would happen every day if you stay fixed to the stars.

Most time-lapse videos of the night sky show the
<a href="ap140526.html">stars and sky moving above a steady Earth</a>.

Here, however, the camera has been forced to rotate so that the
<a href="ap110601.html">stars remain fixed</a>, and the Earth rotates around them.

<a href="https://www.youtube.com/embed/re3oEKX6Fks">The movie</a>,
with each hour is compressed to a second,
dramatically demonstrates the daily rotation of the Earth, called
<a href="https://en.wikipedia.org/wiki/Diurnal_motion">diurnal motion</a>.

<a href="https://www.youtube.com/watch?v=DmwaUBY53YQ">The video</a>
begins by showing an open field in
<a href="https://en.wikipedia.org/wiki/Namibia">Namibia</a>,
<a href="https://en.wikipedia.org/wiki/Africa">Africa</a>,
on a clear day, last year.

Shadows shift as the
<a href="ap190520.html">Earth turns</a>, the
<a href="ap090624.html">shadow of the Earth rises</a> into the sky, the
<a href="ap120207.html">Belt of Venus</a> momentarily appears,
and then day turns into night.

The majestic band of our
<a href="https://imagine.gsfc.nasa.gov/science/objects/milkyway1.html">Milky Way Galaxy</a> stretches across the night sky,
while sunlight-reflecting, Earth-orbiting
<a href="https://www.heavens-above.com/">satellites zoom by</a>.

In the night sky, you can even spot the
<a href="ap180428.html">Large and Small Magellanic Clouds</a>.

The video shows a sky visible from Earth's
<a href="https://en.wikipedia.org/wiki/Southern_Hemisphere">Southern Hemisphere</a>,
but a similar video could be made for every middle latitude on
<a href="https://solarsystem.nasa.gov/planets/earth/overview/">our blue planet</a>.


</p><p> </p><center>
<b> Almost Hyperspace: </b>
<a href="https://apod.nasa.gov/apod/random_apod.html">Random APOD Generator</a> <br>
<b> Tomorrow's picture: </b>open space

<p> </p><hr>
<a href="ap200630.html">&lt;</a>
| <a href="archivepix.html">Archive</a>
| <a href="lib/apsubmit2015.html">Submissions</a>
| <a href="lib/aptree.html">Index</a>
| <a href="https://antwrp.gsfc.nasa.gov/cgi-bin/apod/apod_search">Search</a>
| <a href="calendar/allyears.html">Calendar</a>
| <a href="/apod.rss">RSS</a>
| <a href="lib/edlinks.html">Education</a>
| <a href="lib/about_apod.html">About APOD</a>
| <a href="http://asterisk.apod.com/discuss_apod.php?date=200701">Discuss</a>
| <a href="ap200702.html">&gt;</a>

<hr><p>
<b> Authors &amp; editors: </b>
<a href="http://www.phy.mtu.edu/faculty/Nemiroff.html">Robert Nemiroff</a>
(<a href="http://www.phy.mtu.edu/">MTU</a>) &amp;
<a href="https://antwrp.gsfc.nasa.gov/htmltest/jbonnell/www/bonnell.html">Jerry Bonnell</a> (<a href="http://www.astro.umd.edu/">UMCP</a>)<br>
<b>NASA Official: </b> Phillip Newman
<a href="lib/about_apod.html#srapply">Specific rights apply</a>.<br>
<a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">NASA Web
Privacy Policy and Important Notices</a><br>
<b>A service of:</b>
<a href="https://astrophysics.gsfc.nasa.gov/">ASD</a> at
<a href="https://www.nasa.gov/">NASA</a> /
<a href="https://www.nasa.gov/centers/goddard/">GSFC</a>
<br><b>&amp;</b> <a href="http://www.mtu.edu/">Michigan Tech. U.</a><br>
</p></center>



</body>
<center>
<h1> Astronomy Picture of the Day </h1>
<p>

<a href="archivepix.html">Discover the cosmos!</a>
Each day a different image or photograph of our fascinating universe is
featured, along with a brief explanation written by a professional astronomer.
</p><p>

2020 July 1
<br>
<iframe width="960" height="540" src="https://www.youtube.com/embed/re3oEKX6Fks?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</p></center>
<center>
<b> Our Rotating Earth </b> <br>
<b> Video Credit &amp; Copyright: </b>
<a href="mailto: sklep @at@ artuniverse .dot. pl">Bartosz</a>
<a href="https://www.youtube.com/c/BartoszWojczy%C5%84ski/about">Wojczyński</a>
</center>
<p>

<b> Explanation: </b>
Has your world ever turned upside-down?

It would happen every day if you stay fixed to the stars.

Most time-lapse videos of the night sky show the
<a href="ap140526.html">stars and sky moving above a steady Earth</a>.

Here, however, the camera has been forced to rotate so that the
<a href="ap110601.html">stars remain fixed</a>, and the Earth rotates around them.

<a href="https://www.youtube.com/embed/re3oEKX6Fks">The movie</a>,
with each hour is compressed to a second,
dramatically demonstrates the daily rotation of the Earth, called
<a href="https://en.wikipedia.org/wiki/Diurnal_motion">diurnal motion</a>.

<a href="https://www.youtube.com/watch?v=DmwaUBY53YQ">The video</a>
begins by showing an open field in
<a href="https://en.wikipedia.org/wiki/Namibia">Namibia</a>,
<a href="https://en.wikipedia.org/wiki/Africa">Africa</a>,
on a clear day, last year.

Shadows shift as the
<a href="ap190520.html">Earth turns</a>, the
<a href="ap090624.html">shadow of the Earth rises</a> into the sky, the
<a href="ap120207.html">Belt of Venus</a> momentarily appears,
and then day turns into night.

The majestic band of our
<a href="https://imagine.gsfc.nasa.gov/science/objects/milkyway1.html">Milky Way Galaxy</a> stretches across the night sky,
while sunlight-reflecting, Earth-orbiting
<a href="https://www.heavens-above.com/">satellites zoom by</a>.

In the night sky, you can even spot the
<a href="ap180428.html">Large and Small Magellanic Clouds</a>.

The video shows a sky visible from Earth's
<a href="https://en.wikipedia.org/wiki/Southern_Hemisphere">Southern Hemisphere</a>,
but a similar video could be made for every middle latitude on
<a href="https://solarsystem.nasa.gov/planets/earth/overview/">our blue planet</a>.


</p>
<p> </p>
<center>
<b> Almost Hyperspace: </b>
<a href="https://apod.nasa.gov/apod/random_apod.html">Random APOD Generator</a> <br>
<b> Tomorrow's picture: </b>open space

<p> </p><hr>
<a href="ap200630.html">&lt;</a>
| <a href="archivepix.html">Archive</a>
| <a href="lib/apsubmit2015.html">Submissions</a>
| <a href="lib/aptree.html">Index</a>
| <a href="https://antwrp.gsfc.nasa.gov/cgi-bin/apod/apod_search">Search</a>
| <a href="calendar/allyears.html">Calendar</a>
| <a href="/apod.rss">RSS</a>
| <a href="lib/edlinks.html">Education</a>
| <a href="lib/about_apod.html">About APOD</a>
| <a href="http://asterisk.apod.com/discuss_apod.php?date=200701">Discuss</a>
| <a href="ap200702.html">&gt;</a>

<hr><p>
<b> Authors &amp; editors: </b>
<a href="http://www.phy.mtu.edu/faculty/Nemiroff.html">Robert Nemiroff</a>
(<a href="http://www.phy.mtu.edu/">MTU</a>) &amp;
<a href="https://antwrp.gsfc.nasa.gov/htmltest/jbonnell/www/bonnell.html">Jerry Bonnell</a> (<a href="http://www.astro.umd.edu/">UMCP</a>)<br>
<b>NASA Official: </b> Phillip Newman
<a href="lib/about_apod.html#srapply">Specific rights apply</a>.<br>
<a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">NASA Web
Privacy Policy and Important Notices</a><br>
<b>A service of:</b>
<a href="https://astrophysics.gsfc.nasa.gov/">ASD</a> at
<a href="https://www.nasa.gov/">NASA</a> /
<a href="https://www.nasa.gov/centers/goddard/">GSFC</a>
<br><b>&amp;</b> <a href="http://www.mtu.edu/">Michigan Tech. U.</a><br>
</p></center>
<body bgcolor="#F4F4FF" text="#000000" link="#0000FF" vlink="#7F0F9F" alink="#FF0000">

<center>
<h1> Astronomy Picture of the Day </h1>
<p>

<a href="archivepix.html">Discover the cosmos!</a>
Each day a different image or photograph of our fascinating universe is
featured, along with a brief explanation written by a professional astronomer.
</p><p>

2020 July 1
<br>
<iframe width="960" height="540" src="https://www.youtube.com/embed/re3oEKX6Fks?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</p></center>

<center>
<b> Our Rotating Earth </b> <br>
<b> Video Credit &amp; Copyright: </b>
<a href="mailto: sklep @at@ artuniverse .dot. pl">Bartosz</a>
<a href="https://www.youtube.com/c/BartoszWojczy%C5%84ski/about">Wojczyński</a>
</center> <p>

<b> Explanation: </b>
Has your world ever turned upside-down?

It would happen every day if you stay fixed to the stars.

Most time-lapse videos of the night sky show the
<a href="ap140526.html">stars and sky moving above a steady Earth</a>.

Here, however, the camera has been forced to rotate so that the
<a href="ap110601.html">stars remain fixed</a>, and the Earth rotates around them.

<a href="https://www.youtube.com/embed/re3oEKX6Fks">The movie</a>,
with each hour is compressed to a second,
dramatically demonstrates the daily rotation of the Earth, called
<a href="https://en.wikipedia.org/wiki/Diurnal_motion">diurnal motion</a>.

<a href="https://www.youtube.com/watch?v=DmwaUBY53YQ">The video</a>
begins by showing an open field in
<a href="https://en.wikipedia.org/wiki/Namibia">Namibia</a>,
<a href="https://en.wikipedia.org/wiki/Africa">Africa</a>,
on a clear day, last year.

Shadows shift as the
<a href="ap190520.html">Earth turns</a>, the
<a href="ap090624.html">shadow of the Earth rises</a> into the sky, the
<a href="ap120207.html">Belt of Venus</a> momentarily appears,
and then day turns into night.

The majestic band of our
<a href="https://imagine.gsfc.nasa.gov/science/objects/milkyway1.html">Milky Way Galaxy</a> stretches across the night sky,
while sunlight-reflecting, Earth-orbiting
<a href="https://www.heavens-above.com/">satellites zoom by</a>.

In the night sky, you can even spot the
<a href="ap180428.html">Large and Small Magellanic Clouds</a>.

The video shows a sky visible from Earth's
<a href="https://en.wikipedia.org/wiki/Southern_Hemisphere">Southern Hemisphere</a>,
but a similar video could be made for every middle latitude on
<a href="https://solarsystem.nasa.gov/planets/earth/overview/">our blue planet</a>.


</p><p> </p><center>
<b> Almost Hyperspace: </b>
<a href="https://apod.nasa.gov/apod/random_apod.html">Random APOD Generator</a> <br>
<b> Tomorrow's picture: </b>open space

<p> </p><hr>
<a href="ap200630.html">&lt;</a>
| <a href="archivepix.html">Archive</a>
| <a href="lib/apsubmit2015.html">Submissions</a>
| <a href="lib/aptree.html">Index</a>
| <a href="https://antwrp.gsfc.nasa.gov/cgi-bin/apod/apod_search">Search</a>
| <a href="calendar/allyears.html">Calendar</a>
| <a href="/apod.rss">RSS</a>
| <a href="lib/edlinks.html">Education</a>
| <a href="lib/about_apod.html">About APOD</a>
| <a href="http://asterisk.apod.com/discuss_apod.php?date=200701">Discuss</a>
| <a href="ap200702.html">&gt;</a>

<hr><p>
<b> Authors &amp; editors: </b>
<a href="http://www.phy.mtu.edu/faculty/Nemiroff.html">Robert Nemiroff</a>
(<a href="http://www.phy.mtu.edu/">MTU</a>) &amp;
<a href="https://antwrp.gsfc.nasa.gov/htmltest/jbonnell/www/bonnell.html">Jerry Bonnell</a> (<a href="http://www.astro.umd.edu/">UMCP</a>)<br>
<b>NASA Official: </b> Phillip Newman
<a href="lib/about_apod.html#srapply">Specific rights apply</a>.<br>
<a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">NASA Web
Privacy Policy and Important Notices</a><br>
<b>A service of:</b>
<a href="https://astrophysics.gsfc.nasa.gov/">ASD</a> at
<a href="https://www.nasa.gov/">NASA</a> /
<a href="https://www.nasa.gov/centers/goddard/">GSFC</a>
<br><b>&amp;</b> <a href="http://www.mtu.edu/">Michigan Tech. U.</a><br>
</p></center>



</body>
<html><head>
<title>Astronomy Picture of the Day
</title>
<!-- gsfc meta tags -->
<meta name="orgcode" content="661">
<meta name="rno" content="phillip.a.newman">
<meta name="content-owner" content="Jerry.T.Bonnell.1">
<meta name="webmaster" content="Stephen.F.Fantasia.1">
<meta name="description" content="A different astronomy and space science
related image is featured each day, along with a brief explanation.">
<!-- -->
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="keywords" content="Earth, diurnal motion, sky">
<!-- -->
<script async="" src="https://www.google-analytics.com/analytics.js"></script><script id="_fed_an_ua_tag" src="//dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=NASA">
</script>

</head>

<body bgcolor="#F4F4FF" text="#000000" link="#0000FF" vlink="#7F0F9F" alink="#FF0000">

<center>
<h1> Astronomy Picture of the Day </h1>
<p>

<a href="archivepix.html">Discover the cosmos!</a>
Each day a different image or photograph of our fascinating universe is
featured, along with a brief explanation written by a professional astronomer.
</p><p>

2020 July 1
<br>
<iframe width="960" height="540" src="https://www.youtube.com/embed/re3oEKX6Fks?rel=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</p></center>

<center>
<b> Our Rotating Earth </b> <br>
<b> Video Credit & Copyright: </b>
<a href="mailto: sklep @at@ artuniverse .dot. pl">Bartosz</a>
<a href="https://www.youtube.com/c/BartoszWojczy%C5%84ski/about">Wojczyński</a>
</center> <p>

<b> Explanation: </b>
Has your world ever turned upside-down?

It would happen every day if you stay fixed to the stars.

Most time-lapse videos of the night sky show the
<a href="ap140526.html">stars and sky moving above a steady Earth</a>.

Here, however, the camera has been forced to rotate so that the
<a href="ap110601.html">stars remain fixed</a>, and the Earth rotates around them.

<a href="https://www.youtube.com/embed/re3oEKX6Fks">The movie</a>,
with each hour is compressed to a second,
dramatically demonstrates the daily rotation of the Earth, called
<a href="https://en.wikipedia.org/wiki/Diurnal_motion">diurnal motion</a>.

<a href="https://www.youtube.com/watch?v=DmwaUBY53YQ">The video</a>
begins by showing an open field in
<a href="https://en.wikipedia.org/wiki/Namibia">Namibia</a>,
<a href="https://en.wikipedia.org/wiki/Africa">Africa</a>,
on a clear day, last year.

Shadows shift as the
<a href="ap190520.html">Earth turns</a>, the
<a href="ap090624.html">shadow of the Earth rises</a> into the sky, the
<a href="ap120207.html">Belt of Venus</a> momentarily appears,
and then day turns into night.

The majestic band of our
<a href="https://imagine.gsfc.nasa.gov/science/objects/milkyway1.html">Milky Way Galaxy</a> stretches across the night sky,
while sunlight-reflecting, Earth-orbiting
<a href="https://www.heavens-above.com/">satellites zoom by</a>.

In the night sky, you can even spot the
<a href="ap180428.html">Large and Small Magellanic Clouds</a>.

The video shows a sky visible from Earth's
<a href="https://en.wikipedia.org/wiki/Southern_Hemisphere">Southern Hemisphere</a>,
but a similar video could be made for every middle latitude on
<a href="https://solarsystem.nasa.gov/planets/earth/overview/">our blue planet</a>.


</p><p> </p><center>
<b> Almost Hyperspace: </b>
<a href="https://apod.nasa.gov/apod/random_apod.html">Random APOD Generator</a> <br>
<b> Tomorrow's picture: </b>open space

<p> </p><hr>
<a href="ap200630.html">&lt;</a>
| <a href="archivepix.html">Archive</a>
| <a href="lib/apsubmit2015.html">Submissions</a>
| <a href="lib/aptree.html">Index</a>
| <a href="https://antwrp.gsfc.nasa.gov/cgi-bin/apod/apod_search">Search</a>
| <a href="calendar/allyears.html">Calendar</a>
| <a href="/apod.rss">RSS</a>
| <a href="lib/edlinks.html">Education</a>
| <a href="lib/about_apod.html">About APOD</a>
| <a href="http://asterisk.apod.com/discuss_apod.php?date=200701">Discuss</a>
| <a href="ap200702.html">&gt;</a>

<hr><p>
<b> Authors &amp; editors: </b>
<a href="http://www.phy.mtu.edu/faculty/Nemiroff.html">Robert Nemiroff</a>
(<a href="http://www.phy.mtu.edu/">MTU</a>) &amp;
<a href="https://antwrp.gsfc.nasa.gov/htmltest/jbonnell/www/bonnell.html">Jerry Bonnell</a> (<a href="http://www.astro.umd.edu/">UMCP</a>)<br>
<b>NASA Official: </b> Phillip Newman
<a href="lib/about_apod.html#srapply">Specific rights apply</a>.<br>
<a href="https://www.nasa.gov/about/highlights/HP_Privacy.html">NASA Web
Privacy Policy and Important Notices</a><br>
<b>A service of:</b>
<a href="https://astrophysics.gsfc.nasa.gov/">ASD</a> at
<a href="https://www.nasa.gov/">NASA</a> /
<a href="https://www.nasa.gov/centers/goddard/">GSFC</a>
<br><b>&amp;</b> <a href="http://www.mtu.edu/">Michigan Tech. U.</a><br>
</p></center>



</body></html>
"""

//parseAPODHTML(html)

let boldPattern = try? NSRegularExpression(pattern: #"(?<=<b>).*(?=<\/b>)"#)
let imageCreditLabelPattern = try? NSRegularExpression(pattern: #"(?<=<b>)[^<]*?Credit[^<]*?(?=<\/b>)"#)
let range = NSRange(location: 0, length: html.count)


let titleRange = boldPattern!.rangeOfFirstMatch(in: html, range: range)
let title = html[Range(titleRange, in: html)!].trimmingCharacters(in: .whitespaces)


var explanation = ""
var imageCreditLabel = ""
var imageCredit = ""

for line in html.components(separatedBy: "<p>") {
	let paragraph = line.replacingOccurrences(of: #"\s"#, with: " ", options: .regularExpression)
	if paragraph.contains("Credit") {
		for part in paragraph.components(separatedBy: "<center>") {
			if part.contains("Credit") {
				if let creditLabelRange = imageCreditLabelPattern?.rangeOfFirstMatch(in: part, range: NSRange(location: 0, length: part.count)) {
					let stringRange = Range(creditLabelRange, in: part)! as Range<String.Index>
					
					imageCreditLabel = part[stringRange].trimmingCharacters(in: .whitespaces)
				}
				imageCredit = part.replacingOccurrences(of: #"<b>.*Credit.*<\/b>"#, with: "", options: .regularExpression).replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
			}
		}
	}
}

let dateString = html.components(separatedBy: "<p>")[2].replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: #"<br>.*"#, with: "", options: .regularExpression)

print(dateString, imageCreditLabel, imageCredit)

//struct APODItem {
//	var title = ""
//	var link = ""
//	var imageLink = ""
//	var description = ""
//	var explanation = ""
//}
//
//class APODFetcher: NSObject, XMLParserDelegate {
//	let url: URL!
//	let parser: XMLParser!
//	var items: [APODItem] = []
//
//	private let keys = ["title", "link", "description"]
//
//	var currentValue = ""
//	var currentItem = [String: String]()
//
//	override init() {
//		url = URL(string: "https://apod.nasa.gov/apod.rss") ?? URL(string: "")!
//		parser = XMLParser(contentsOf: url)
//
//		super.init()
//
//		parser.delegate = self
//	}
//
//	func getImage() {
//		parser.parse()
//	}
//
//	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//		currentValue = ""
//	}
//
//	func parser(_ parser: XMLParser, foundCharacters string: String) {
//		currentValue += string
//	}
//
//	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//
//		if keys.contains(elementName) {
//			currentItem[elementName] = currentValue
//		} else if elementName == "item" {
//			guard let title = currentItem["title"], let link = currentItem["link"], let description = currentItem["description"] else {
//				return
//			}
//			items.append(APODItem(title: title, link: link, description: description))
//		}
//
//	}
//
//	func parserDidEndDocument(_ parser: XMLParser) {
//		print(items)
//	}
//}
//
////let fetcher = APODFetcher()
////fetcher.getImage()
//let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//
//func date(from string: String) -> Date {
//	let stringComponents = string.components(separatedBy: " ")
//	let date = Date()
//	var dateComponents = DateComponents()
//
//	dateComponents.year = Int(stringComponents[0]) ?? Calendar.current.component(.year, from: date)
//	dateComponents.month =  1 + (months.firstIndex(of: stringComponents[1]) ?? (Calendar.current.component(.month, from: date) - 1))
//	dateComponents.day = Int(stringComponents[2]) ?? Calendar.current.component(.day, from: date)
//
//	// Create date from components
//	return Calendar.current.date(from: dateComponents)!
//}
//
//func parseAPODHTML(_ html: String) -> APODItem {
//	let boldPattern = try? NSRegularExpression(pattern: #"(?<=<b>).*(?=<\/b>)"#)
//	let imageLinkPattern = try? NSRegularExpression(pattern: #"(?<=href=").*\.jpg(?=">)"#)
//	let range = NSRange(location: 0, length: html.count)
//
//
//	let titleRange = boldPattern!.rangeOfFirstMatch(in: html, range: range)
//	let title = html[Range(titleRange, in: html)!].trimmingCharacters(in: .whitespaces)
//
//	let imageRange = imageLinkPattern!.rangeOfFirstMatch(in: html, range: range)
//	let imageLink = "https://apod.nasa.gov/apod/" + html[Range(imageRange, in: html)!].trimmingCharacters(in: .whitespaces)
//
//	var explanation = ""
//	var imageCredit = ""
//
//	for line in html.components(separatedBy: "<p>") {
//		print(line)
//		print("----")
//		let paragraph = line.replacingOccurrences(of: #"\s"#, with: " ", options: .regularExpression)
//		if paragraph.contains("<b> Explanation: </b>") {
//			explanation = paragraph.replacingOccurrences(of: "<b> Explanation: </b>", with: "").replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
//		} else if paragraph.contains("Image Credit") {
//
//			for part in paragraph.components(separatedBy: "<center>") {
//				if part.contains("Image Credit") {
//					imageCredit = part.replacingOccurrences(of: #"<b>.*Image Credit.*<\/b>"#, with: "", options: .regularExpression).replacingOccurrences(of: #"<.+?>"#, with: "", options: .regularExpression).replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
//				}
//			}
//		}
//	}
//
//	let dateString = html.components(separatedBy: "<p>")[2].replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: #"<br>.*"#, with: "", options: .regularExpression)
//
//
//	print(date(from: dateString))
//	print("Explanation: \(explanation)")
//	print("Image Credit: \(imageCredit)")
//	return APODItem(title: title, imageLink: imageLink, explanation: explanation)
//}
//

print()
let sessionConfiguration = URLSessionConfiguration.default
//let session = URLSession(configuration: sessionConfiguration)

func getHTML(at url: URL) {
	var request = URLRequest(url: url)
	request.httpMethod = "GET"

	let task = session.dataTask(with: request) { (data, response, error) in
		guard let data = data else {
			print(error!)
			return
		}
		guard let html = String(data: data, encoding: .utf8) else { return }

		print(parseAPODHTML(html))
	}

	task.resume()
}


//let apodURL = URL(string: "https://apod.nasa.gov/apod/astropix.html")!
//getHTML(at: apodURL)

if let apodData = try? Data(contentsOf: apodURL) {
	if let apodHTML = String(data: apodData, encoding: .utf8) {
		print(apodHTML)
	}
}
