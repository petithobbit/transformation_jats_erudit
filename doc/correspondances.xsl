<?xml version="1.0" encoding="UTF-8"?>

<!-- <xsl:outputencoding="ISO-8859-1"method="xml" indent="yes"/> -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="correspondances">

        <!-- code html -->
        <!-- head -->
        <html lang="fr">
            <head>
                <meta charset="utf-8"/>
                <meta name="author" content="{@auteur}"/>
                <xsl:if test="@collaboration">
                    <meta name="collaborateur" content="{@collaboration}"/>
                </xsl:if>
                <link rel="stylesheet" type="text/css" href="correspondances.css"/>
                <title>documentation transformation</title>
            </head>
            <!-- body -->
            <body id="page">
                <!-- header -->
                <header>
                    <h1>Banque de correspondances</h1>
                    <h3> Valide pour la version <xsl:value-of select="@version"/>. Modifiée le <xsl:value-of
                            select="@date_modification"/> par <xsl:value-of select="@auteur"/></h3>
                    <p>Correspondances utilisées dans le cadre de la transformation du standard <a
                            href="{@source_reference}" target="_blank"><xsl:apply-templates
                                select="@standard_source"/></a> vers le standard <a
                            href="{@cible_reference}" target="_blank"><xsl:apply-templates
                                select="@standard_cible"/>.</a></p>
                </header>
                <main>
                    <table>
                        <caption>Tableau des correspondances</caption>
                        <thead>
                            <tr>
                                <th>
                                    <xsl:apply-templates select="@standard_source"/>
                                </th>
                                <th>
                                    <xsl:apply-templates select="@standard_cible"/>
                                </th>
                                <th>Équivalence</th>
                                <th>Commentaires</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:apply-templates/>
                        </tbody>
                    </table>
                </main>
                <footer/>
            </body>
        </html>
    </xsl:template>

    <!-- templates -->
    <!-- main -->
    

    <xsl:template match="correspondance">
        <xsl:for-each select=".">
            <tr>
                <td title="{./source/definition}">
                    <xsl:choose>
                    <xsl:when test="./source/element/@reference">
                        <a href="{./source/element/@reference}" target="_blank"><xsl:value-of select="./source/element"/></a>
                    </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./source/element"/> 
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td title="{./cible/definition}">
                    <xsl:choose>
                        <xsl:when test="./cible/element/@reference">
                            <a href="{./cible/element/@reference}" target="_blank"><xsl:value-of select="./cible/element"/></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./cible/element"/> 
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </td>
                <td title="{./equivalence/*/@definition}">
                    <xsl:value-of select="./equivalence/*/name()"></xsl:value-of> 
                </td>
                <td>
                    <xsl:value-of select="./commentaires"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
 <!--
     <xsl:choose>
     <xsl:when test="$CreatedDate > $IDAppendedDate">
       <h2>mooooooooooooo</h2>
     </xsl:when>
     <xsl:when test="$CreatedDate = $IDAppendedDate">
       <h2>booooooooooooo</h2>
     </xsl:when>
     <xsl:otherwise>
      <h2>dooooooooooooo</h2>
     </xsl:otherwise>
   </xsl:choose>
     
     
     
    <xsl:template match="definition"/>
    
    <xsl:template match="source/element">
        <td>
            <xs:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="cible/element">
        <td>
            <xs:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="equivalence">
        <td>
            <xs:value-of select="name()"/>
        </td>
    </xsl:template>
    <xsl:template match="commentaires">
        <td>
            <xs:apply-templates select="commentaires/text()"/>
            <br/>
        </td>
    </xsl:template>
    -->

</xsl:stylesheet>
