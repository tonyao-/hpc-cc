<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!-- The TOC links in the titles, and in blue. -->
<xsl:param name="latex.hyperparam">colorlinks,linkcolor=blue,pdfstartview=FitH</xsl:param>

<!-- Put the dblatex logo -->
<xsl:param name="doc.publisher.show">1</xsl:param>

<!-- List the examples and equations too -->
<xsl:param name="doc.lot.show">figure,table,example</xsl:param>

<!-- Collaborators -->
<xsl:param name="doc.collab.show">1</xsl:param>

<!-- История изменений -->
<xsl:param name="latex.output.revhistory">1</xsl:param>

<!-- Оглавление -->
<xsl:param name="doc.toc.show">1</xsl:param>

<!-- Кодировка -->
<xsl:param name="latex.unicode.use">1</xsl:param>
<xsl:param name="latex.encoding">utf8</xsl:param>

</xsl:stylesheet>
