---
title: Enable SSL Connections to SQL Server
date: 2013-02-03
author: Beej
tags:
  - Database
  - Security
thumbnail-img: /images/uploads/2013/enable-ssl-connections-to-sql-server-thumbnail.png
---
<table border="1" cellpadding="2" cellspacing="0">
  <tr>
    <td valign="top">
      “SQL Server Transport Encryption” is a good Google phrase for this technology.<br /> Reference: <a href="https://msdn.microsoft.com/en-us/library/ms191192.aspx" title="https://msdn.microsoft.com/en-us/library/ms191192.aspx">https://msdn.microsoft.com/en-us/library/ms191192.aspx</a>
    </td>
    
    <td valign="top">
    </td>
  </tr>
  
  <tr>
    <td valign="top">
      <h4>
        Obtain an SSL Certificate
      </h4>
      
      <p>
        A self signed certificate is easy and works fine... here’s one way:
      </p>
      
      <ul>
        <li>
          Get the IIS 6.0 Resource Kit Tools: <a href="https://www.microsoft.com/download/en/confirmation.aspx?id=17275">https://www.microsoft.com/download/en/confirmation.aspx?id=17275</a>
        </li>
        <li>
          All you'll need is the "SelfSSL.exe" tool so the custom install is minimal.
        </li>
        <li>
          Find SelfSSL.exe in default install path: C:Program FilesIIS Resources
        </li>
        <li>
          Good reference for SelfSSL usage: <a href="https://www.sslshopper.com/article-how-to-create-a-self-signed-certificate-in-iis-7.html">https://www.sslshopper.com/article-how-to-create-a-self-signed-certificate-in-iis-7.html</a>, scroll down to "Generate a Self Signed Certificate with the Correct Common Name"
        </li>
        <li>
          Command line example: <div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:7d965c1e-472b-4510-b2a8-534f6536b154" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
            <div class="le-pavsc-container">
              <div style="background: #fff; overflow: auto;">
                <ol style="background: #1e1e1e; margin: 0; padding: 0 0 0 5px; white-space: nowrap;">
                  <li>
                    SelfSSL /N:CN=MWR-TRO-V2 /V:1999999
                  </li>
                </ol>
              </div>
            </div>
          </div>
          
          <ul>
            <li>
              The /V: part is the validity duration of your cert, in days. I believe 1999999 is the max, which corresponds to around 5475 years in the future (that ought'a last ya ;)
            </li>
            <li>
              The /N:CN= part is the “Common Name” this cert will be tied to… in this case that needs to be the true machine name of your database server.
            </li>
          </ul>
        </li>
        
        <li>
          “Do you want to replace the SSL settings for site 1 (Y/N)?” => No
        </li>
        <li>
          Now you have a cert registered in your “personal certificate store” &#8211; next we’ll extract it for installation on db server.
        </li>
      </ul>
    </td>
    
    <td valign="top">
    </td>
  </tr>
  
  <tr>
    <td valign="top">
      Fire up the MMC “Certificates Console” to manage your new cert </p> 
      
      <ul>
        <li>
          Good reference: <a href="https://support.microsoft.com/kb/276553)">https://support.microsoft.com/kb/276553)</a>
        </li>
        <li>
          Open the MMC console: Start > Run > mmc [enter] (or Windows-R) (MMC Fig.1)
        </li>
        <li>
          Add the cert snapin: click File > Add/Remove Snap-in (MMC Fig.2)
        </li>
        <li>
          select Certificates under Available snap-ins… and hit Add button… (MMC Fig.3)
        </li>
        <li>
          select Computer Account… then Next… (MMC Fig.4)
        </li>
        <li>
          select Local computer, and then Finish… (MMC Fig.5)
        </li>
        <li>
          lastly, hit OK (MMC Fig.6)
        </li>
      </ul>
      
      <ul>
        <li>
          You may wish to save this MMC configuration for future convenience (MMC Fig.7)
        </li>
      </ul>
    </td>
    
    <td valign="top">
      Screenshots...</p> 
      
      <div class="expandee">
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:2b3a630b-f36d-466a-bbce-6343743eca79" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-214fdca2f4c4.png" rel="thumbnail" title="MMC Fig.1"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-thumbnail.png" height="364" width="294" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:18b2ff5f-6851-4175-8725-92e7640f4ef8" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-9f8d8b939f4b.png" rel="thumbnail" title="MMC Fig.1"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-e01d46e3ccbf.png" height="255" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:dfb63c1b-7968-4f2d-8883-50cf032dd458" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-55d4e629d776.png" rel="thumbnail" title="MMC Fig.3"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-6fd8557c47e9.png" height="282" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:9f3b02fd-f351-4fd3-8186-06ff3ced84e9" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-5bad7005c868.png" rel="thumbnail" title="MMC Fig.4"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-308f53813a8a.png" height="292" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:668dc8d5-ca09-461f-a4ed-c6b8be286099" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-854e695222ce.png" rel="thumbnail" title="MMC Fig.5"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-a4774201da0f.png" height="292" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:c540f85f-20d3-41ba-a8be-a46f0ce1d345" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-c583879a7f9a.png" rel="thumbnail" title="MMC Fig.6"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-7a1d1994bba6.png" height="282" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:c88d125f-445c-4f80-b60e-3ca0220926c4" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-5cb5c3fea9ac.png" rel="thumbnail" title="MMC Fig.7"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-b7400066c2d3.png" height="249" width="335" /></a>
        </div>
      </div>
    </td>
  </tr>
  
  <tr>
    <td valign="top">
      <h4>
        Export the cert as a pfx file
      </h4>
      
      <p>
        …to be installed on your database server
      </p>
      
      <ul>
        <li>
          Certs installed via the above process will be your "Personal > Certificates" <em>folder</em> (Export Fig.1)
        </li>
        <li>
          Right mouse desired certifcate > All Tasks > Export > Next ... (Export Fig.2)
        </li>
        <li>
          “Export the private key?” => Yes … Next… (Export Fig.3)
        </li>
        <li>
          Select PFX format, "Include all certs...", "Export extended", NOT “Delete…”, Next … (Export Fig.4)
        </li>
        <li>
          Enter a password, hit Next… (Export Fig.5) – ** REMEMBER THAT PASSWORD **
        </li>
        <li>
          Save the pfx file (Export Fig.6)
        </li>
        <li>
          Finish… OK (Export Fig.7)
        </li>
      </ul>
    </td>
    
    <td valign="top">
      Screenshots...</p> 
      
      <div class="expandee">
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:dd057907-b970-479e-918f-590a65285323" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-9e7d855b5a0e.png" rel="thumbnail" title="Export Fig.1"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-6eb97a584bb4.png" height="262" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:fec4d645-e6c9-45e0-b780-431b7917cb97" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-c8f4a320ca30.png" rel="thumbnail" title="Export Fig.2"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-a62240db63fc.png" height="256" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:c26a30e5-a3e5-4674-bfa8-ae27b9ff368f" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-a9b8a733aa02.png" rel="thumbnail" title="Export Fig.3"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-1bdd43cf928b.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:7893e848-d68b-4d5f-8d3b-8e3137bf632b" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-e4d830b6b0a8.png" rel="thumbnail" title="Export Fig.4"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-848d68d47450.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:6f7d6687-46f5-4a20-9269-a894b0c44bf7" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-3a69f566a246.png" rel="thumbnail" title="Export Fig.5"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-3e792ada0b70.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:cc606be5-ca7b-499e-910c-5b13be68bed8" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-9a86e0420309.png" rel="thumbnail" title="Export Fig.6"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-6e409c4ee078.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:5e195969-9281-4966-acac-77a4ba7bf448" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-3f903d49f131.png" rel="thumbnail" title="Export Fig.7"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-2a997473cce1.png" height="356" width="335" /></a>
        </div>
      </div>
    </td>
  </tr>
  
  <tr>
    <td valign="top">
      <h4>
        Import cert on database server
      </h4>
      
      <ul>
        <li>
          Login to your DB server desktop
        </li>
        <li>
          Launch MMC Cert Console same as above
        </li>
        <li>
          Go to Personal > Certs
        </li>
        <li>
          Right mouse All Tasks > "Import"… (Import Fig.1)
        </li>
        <li>
          Next… (Import Fig.2)
        </li>
        <li>
          Browse… (Import Fig.3)
        </li>
        <li>
          Next … (Import Fig.4)
        </li>
        <li>
          Enter Password, select “Mark this key as exportable”, Next… (Import Fig.5)
        </li>
        <li>
          “Place all certificates in the following store” => Personal… Next… (Import Fig.6)
        </li>
        <li>
          Finish (Import Fig.7)
        </li>
      </ul>
      
      <ul>
      </ul>
    </td>
    
    <td valign="top">
      Screenshots...</p> 
      
      <div class="expandee">
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:cf805770-e24d-49a0-a758-cef13c9a87b3" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-429ff39d5f58.png" rel="thumbnail" title="Import Fig.1"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-845e8f61aa16.png" height="262" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:77258f51-d169-4be5-9bef-6073b1be1614" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-e66a18873ac5.png" rel="thumbnail" title="Import Fig.2"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-94e6b01ae9b0.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:5bfb8c17-0493-468d-b0d9-542aad18c36c" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-1d2f840ad960.png" rel="thumbnail" title="Import Fig.3"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-9657cd9e08c6.png" height="254" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:42e75b74-7310-40a8-a052-c72b7288aaf4" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-9596e4f81864.png" rel="thumbnail" title="Import Fig.4"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-2f61dc1e9902.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:87808f3b-93a3-4e37-9178-b1832550d854" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-85db0a4da817.png" rel="thumbnail" title="Import Fig.5"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-fb2753b9b7ce.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:39ad9703-f588-4a11-ae04-c8faa4d2c66e" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-3ee1cd109239.png" rel="thumbnail" title="Import Fig.6"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-6b0a931e8874.png" height="356" width="335" /></a>
        </div>
        
        <div class="wlWriterEditableSmartContent" id="scid:8747F07C-CDE8-481f-B0DF-C6CFD074BF67:8aedd55c-a98b-4eb6-a8d9-28d698f0af8c" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
          <a href="/images/uploads/2013/enable-ssl-connections-to-sql-server-a01e2c42d234.png" rel="thumbnail" title="Import Fig.7"><img border="0" src="/images/uploads/2013/enable-ssl-connections-to-sql-server-c3011d0aa878.png" height="356" width="335" /></a>
        </div>
      </div>
    </td>
  </tr>
  
  <tr>
    <td valign="top">
      <h4>
        Activate SSL encryption on DB server
      </h4>
      
      <ul>
        <li>
          Fire up SQL Server’s Network Configuration Utility <ul>
            <li>
              Start&nbsp; > All Programs > Microsoft SQL Server {version} > Configuration Tools > SQL Server Configuration Manager"&nbsp;
            </li>
          </ul>
        </li>
        
        <li>
          then under "SQL Server Network Configuration"
        </li>
        <li>
          Right click "Protocols for MSSQLServer"
        </li>
        <li>
          select "Properties"
        </li>
        <li>
          set&nbsp; "Flags tab > Force Encryption" to Yes
        </li>
        <li>
          and select the installed cert on the "Certificates" tab
        </li>
        <li>
          voila!
        </li>
        <li>
          STOP AND RESTART THE SQL SERVER SERVICE
        </li>
        <li>
          login to the instance with an SSMS Query window
        </li>
        <li>
          fire this command to verify all connections are encrypted: <div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:74bca4ba-60f3-46e4-8e19-543f09036fe4" style="display: inline; float: none; margin: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px;">
            <div class="le-pavsc-container">
              <div style="background: #fff; overflow: auto;">
                <ol style="background: #ffffff; margin: 0; padding: 0 0 0 5px; white-space: nowrap;">
                  <li>
                    SELECT encrypt_option, * FROM sys.dm_exec_connections WHERE session_id = @@SPID
                  </li>
                </ol>
              </div>
            </div>
          </div>
        </li>
        
        <li>
          Tip: SP_WHO2 is handy for obtaining spids
        </li>
      </ul>
    </td>
    
    <td valign="top">
    </td>
  </tr>
</table>