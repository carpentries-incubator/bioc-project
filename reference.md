---
{}
---

## Glossary

{:auto\_ids}

AnnotationData package
:   Type of Bioconductor package that provides databases of molecular annotations (e.g., genes, proteins, pathways).

biocViews
:   Directed acyclic graphs of terms from a controlled vocabulary, used to categorize R packages in the Bioconductor repository.
The `biocViews` can be browsed on the [Bioconductor website][biocviews-site].

ExperimentData package
:   Type of Bioconductor package that provides experimental datasets, immediately available as standard Bioconductor objects.
This type of package is often used in [package vignettes](#vignette), to conveniently import data used to demonstrate the functionality of other packages as well as larger workflows.
Experiment data packages can be explored on the [biocViews page][bioc-experimentdata].

S4 class
:   R has three object-oriented programming (OOP) systems: S3, S4 and R6 (or Reference Classes).
S4 is system that defines formal classes, using an implementation that is stricter than the S3 class system.
Classes define the conceptual structure of S4 objects, while S4 objects represent practical instances of their class. See [S4 object](#s4-object).

S4 class slot
:   Slots can be seen as parts, elements, properties, or attributes of S4 objects.
Each slot is defined by its name and the data type that it may contain.

S4 generic
:   Template function for [S4 methods](#s4-method) that defines the arguments considered for [S4 method dispatch](s4-method-dispatch).

S4 method
:   Instance of an [S4 generic](#s4-generic) for a particular combination of classes across the arguments considered for [S4 method dispatch](s4-method-dispatch).

S4 method dispatch
:   Mechanism allowing R to identify and call the implementation of an [S4 generic](#s4-generic) R function according to the class of object(s) given as argument(s).

S4 object
:   S4 objects are instances of S4 classes, in the same way that an actual car is an instance of the definition of a car that one would find in a dictionary.

Software package
:   Type of Bioconductor package that provides implementations of methodologies for processing experimental data.

Vignette
:   Document(s) in PDF or HTML format, distributed and installed alongside package code,
providing long-form documentation that demonstrates the use of the package functionality in the context of an example workflow.
Vignettes typically use standard datasets obtained from an [ExperimentData package](#experimentdata-package) or the [*ExperimentHub*](https://bioconductor.org/packages/ExperimentHub/) package.

Workflow package
:   Type of Bioconductor package that exclusively provides vignettes used to demonstrate the use of multiple Bioconductor packages in the context of a large workflow.

## Web resources

*[Bioconductor website][bioconductor-website]*
:   The official Bioconductor website.



[biocviews-site]: https://www.bioconductor.org/packages/release/BiocViews.html
[bioc-experimentdata]: https://www.bioconductor.org/packages/release/BiocViews.html#___ExperimentData
[bioconductor-website]: https://bioconductor.org/



