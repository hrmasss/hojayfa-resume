#import "@preview/imprecv:1.0.1": *

#let cvdata = yaml("data.yml")

#let uservars = (
  headingfont: "Times New Roman",
  bodyfont: "Times New Roman",
  fontsize: 11pt, // 10pt, 11pt, 12pt
  linespacing: 6pt,
  sectionspacing: 0pt,
  showAddress: true, // true/false show address in contact info
  showNumber: true, // true/false show phone number in contact info
  showTitle: true, // true/false show title in heading
  headingsmallcaps: false, // true/false use small caps for headings
  sendnote: false, // set to false to have sideways endnote
)

// Custom heading function with reduced line spacing
#let cvheading(cvdata, uservars) = {
  let name = cvdata.personal.name
  let titles = if uservars.showTitle and "titles" in cvdata.personal { cvdata.personal.titles.join(" | ") } else { "" }
  let location = if uservars.showAddress and "location" in cvdata.personal {
    let loc = cvdata.personal.location
    if "city" in loc and "region" in loc and "country" in loc {
      loc.city + ", " + loc.region + ", " + loc.country
    } else { "" }
  } else { "" }

  // Helper function to clean URLs
  let clean_url(url) = url.replace("https://", "").replace("http://", "")

  // Build contact info array
  let contact_items = ()

  if "email" in cvdata.personal {
    contact_items.push(cvdata.personal.email)
  }

  if uservars.showNumber and "phone" in cvdata.personal {
    contact_items.push(cvdata.personal.phone)
  }

  if "url" in cvdata.personal {
    contact_items.push(clean_url(cvdata.personal.url))
  }

  if "profiles" in cvdata.personal {
    for profile in cvdata.personal.profiles {
      if profile.network in ("LinkedIn", "GitHub") {
        contact_items.push(clean_url(profile.url))
      }
    }
  }

  // Display the heading with tight spacing and full-width centering
  block(width: 100%)[
    #set par(leading: 0.5em, spacing: 0.5em)
    #set align(center)

    #text(size: 24pt, weight: "bold")[#upper(name)]

    #if titles != "" [
      #text(size: 11pt, weight: "bold")[#titles]
    ]

    #if location != "" [
      #text(size: 11pt)[#location]
    ]

    #if contact_items.len() > 0 [
      #text(size: 11pt)[#contact_items.join([  ♦  ])]
    ]
  ]

  v(0.5em)
}

#let customrules(doc) = {
  // add custom document style rules here
  set page(
    paper: "us-letter", // a4, us-letter
    numbering: "1 / 1",
    number-align: center, // left, center, right
    margin: 1.25cm, // 1.25cm, 1.87cm, 2.5cm
  )

  doc
}

#let cvinit(doc) = {
  doc = setrules(uservars, doc)
  doc = showrules(uservars, doc)
  doc = customrules(doc)

  doc
}

// Override empty sections to not display
#let cvaffiliations(cvdata) = []
#let cvawards(cvdata) = []
#let cvcertificates(cvdata) = []
#let cvpublications(cvdata) = []
#let cvreferences(cvdata) = []
#let cvlanguages(cvdata) = []

// ========================================================================== //

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)

// Professional Summary Section
#if "summary" in cvdata.personal [
  #heading(level: 2)[Professional Summary]
  #cvdata.personal.summary
  #v(0.5em)
]

#cvwork(cvdata)
#cveducation(cvdata)
#cvprojects(cvdata)
#cvskills(cvdata)
#cvlanguages(cvdata)
#endnote(uservars)
