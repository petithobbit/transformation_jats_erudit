<?xml version="1.0" encoding="UTF-8"?>

<!-- <xsl:outputencoding="ISO-8859-1"method="xml" indent="yes"/> -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
     
    <xsl:template match="/">
        <html lang="fr">            
            <head>
                <meta charset="utf-8"/>
                <meta name="author" content="Isabelle Bastien"/>
                <link rel="stylesheet" type="text/css" href="banque_correspondance.css" />
                <title>Transformation JATS Érudit</title>
            </head>
            
            <body>
                <header><h1></h1>
                </header>
                <main>
                    <table border="0.5">
                        <thead>
                            <tr>Banque de correspondances</tr>
                        </thead>
                        <tbody>
                            <tr>
                                <th>Élément Jats</th>
                                <th>Élément Érudit</th>
                                <th>Correspondance</th>
                                <th>Notes</th>
                                <xsl:for-each select="banque/correspondance">
                                    <tr>
                                        <td><xs:value-of select="el_jats"/></td>
                                        <td><xs:value-of select="el_erudit"/></td>
                                        <td><xs:value-of select="type_correspondance"/></td>
                                        <td><xs:value-of select="type_correspondance"/></td>
                                        
                                    </tr>
                                </xsl:for-each>
                            </tr>
                           
                        </tbody>
                    </table>
                    
                </main>
                <footer>
                    
                </footer>
            </body>
        </html>    
    </xsl:template>
    
      
    
</xsl:stylesheet>