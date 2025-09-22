<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
    <html>
        <head>
            <title>NGINX RTMP Statistics</title>
            <style>
                body { 
                    font-family: Arial, sans-serif; 
                    background: #f0f0f0; 
                    margin: 20px;
                }
                .container {
                    background: white;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                h1 { color: #333; }
                table { 
                    border-collapse: collapse; 
                    width: 100%; 
                    margin: 20px 0;
                }
                th, td { 
                    border: 1px solid #ddd; 
                    padding: 12px; 
                    text-align: left; 
                }
                th { 
                    background: #007bff; 
                    color: white; 
                }
                tr:nth-child(even) { background: #f9f9f9; }
                .status-live { color: #28a745; font-weight: bold; }
                .status-idle { color: #6c757d; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🎥 NGINX RTMP Statistics</h1>
                
                <h2>📊 Server Info</h2>
                <table>
                    <tr><th>Parameter</th><th>Value</th></tr>
                    <tr><td>Version</td><td><xsl:value-of select="rtmp/nginx_version"/></td></tr>
                    <tr><td>Uptime</td><td><xsl:value-of select="rtmp/uptime"/></td></tr>
                    <tr><td>Accepted</td><td><xsl:value-of select="rtmp/naccepted"/></td></tr>
                    <tr><td>Bandwidth In</td><td><xsl:value-of select="rtmp/bw_in"/></td></tr>
                    <tr><td>Bandwidth Out</td><td><xsl:value-of select="rtmp/bw_out"/></td></tr>
                </table>

                <h2>📺 Live Streams</h2>
                <table>
                    <tr>
                        <th>Application</th>
                        <th>Stream Name</th>
                        <th>Status</th>
                        <th>Client IP</th>
                        <th>Bytes In</th>
                        <th>Bytes Out</th>
                    </tr>
                    <xsl:for-each select="rtmp/server/application">
                        <xsl:for-each select="live/stream">
                            <tr>
                                <td><xsl:value-of select="../../name"/></td>
                                <td><xsl:value-of select="name"/></td>
                                <td class="status-live">LIVE</td>
                                <td><xsl:value-of select="client/address"/></td>
                                <td><xsl:value-of select="bytes_in"/></td>
                                <td><xsl:value-of select="bytes_out"/></td>
                            </tr>
                        </xsl:for-each>
                    </xsl:for-each>
                </table>

                <h2>👥 Connected Clients</h2>
                <table>
                    <tr>
                        <th>Client ID</th>
                        <th>Address</th>
                        <th>Connected</th>
                        <th>Type</th>
                    </tr>
                    <xsl:for-each select="rtmp/server/application/live/stream/client">
                        <tr>
                            <td><xsl:value-of select="id"/></td>
                            <td><xsl:value-of select="address"/></td>
                            <td><xsl:value-of select="time"/></td>
                            <td><xsl:value-of select="flashver"/></td>
                        </tr>
                    </xsl:for-each>
                </table>

                <p><em>Last updated: <script>document.write(new Date())</script></em></p>
                <p><a href="/" style="color: #007bff;">← Back to Stream</a></p>
            </div>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
