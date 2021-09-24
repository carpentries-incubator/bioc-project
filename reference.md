---
layout: reference
---

## Glossary

{:auto_ids}

AnnotationData package
:   Type of Bioconductor package that provides databases of molecular annotations (e.g., genes, proteins, pathways).

ExperimentData package
:   Type of Bioconductor package that provides experimental datasets, immediately available as standard Bioconductor objects.
    This type of package is often used in [pakage vignettes](#vignette), to conveniently import data used to demonstrate the functionality of other packages as well as larger workflows.

S4 class
:   R has three object oriented (OO) systems: S3, S4 and R5.
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
    Vignettes typically use standard datasets obtained from an [ExperimentData package](#experimentdata-package) or the [_ExperimentHub_](https://bioconductor.org/packages/ExperimentHub/) package.

Workflow package
:   Type of Bioconductor package that exclusively provides vignettes used to demonstrate the use of multiple Bioconductor packages in the context of a large workflow.

## Web resources

*[Bioconductor website][bioconductor-website]*
:   The official Bioconductor website.

[bioconductor-website]: https://bioconductor.org/

{% include links.md %}
