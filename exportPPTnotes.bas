Attribute VB_Name = "exportPPTnotes"
' ============================================================
' 全局常量：定义基础路径（只需修改这一处）
' ============================================================
Private Const BASE_PATH As String = "/Users/inzisarshuang/Desktop/"

' ============================================================
' 路径测试函数：检查当前基础路径是否可用
' ============================================================
Sub TestBasePath()
    Dim filePath As String
    Dim fileNum As Integer
    Dim testContent As String
    
    filePath = BASE_PATH & "PPT_Path_Test.txt"
    testContent = "这是一个路径测试文件。" & vbCrLf & "生成时间: " & Now()
    
    On Error Resume Next
    fileNum = FreeFile()
    Open filePath For Output As fileNum
    If Err.Number = 0 Then
        Print #fileNum, testContent
        Close fileNum
        MsgBox "路径测试成功！" & vbCrLf & _
               "文件已创建: " & filePath & vbCrLf & _
               "如果这不是您期望的位置，请修改 BASE_PATH 常量。"
    Else
        MsgBox "路径测试失败！" & vbCrLf & _
               "错误: " & Err.Description & vbCrLf & _
               "当前路径: " & BASE_PATH & vbCrLf & _
               "请修改 BASE_PATH 常量。"
    End If
    On Error GoTo 0
End Sub

' ============================================================
' 函数1：导出备注为TXT格式
' ============================================================
Sub ExportNotesToTXT()
    Dim sld As Slide
    Dim notesText As String
    Dim allNotes As String
    Dim i As Integer
    Dim fileNum As Integer
    Dim filePath As String
    
    ' 初始化
    allNotes = ""
    i = 1
    
    ' 收集所有备注
    For Each sld In ActivePresentation.Slides
        notesText = "(No Notes)"
        
        ' 检查是否有备注内容
        If sld.NotesPage.Shapes.Count > 1 Then
            On Error Resume Next
            notesText = sld.NotesPage.Shapes(2).TextFrame.TextRange.text
            If Err.Number <> 0 Or Trim(notesText) = "" Then
                notesText = "(No Notes)"
            End If
            On Error GoTo 0
        End If
        
        ' 添加到总文本
        allNotes = allNotes & "Slide " & i & ":" & vbCrLf
        allNotes = allNotes & CleanText(notesText, "TXT") & vbCrLf & vbCrLf
        
        i = i + 1
    Next sld
    
    ' 直接使用全局常量
    filePath = BASE_PATH & "PPT_Notes.txt"
    fileNum = FreeFile()
    
    On Error Resume Next
    Open filePath For Output As fileNum
    If Err.Number = 0 Then
        Print #fileNum, allNotes
        Close fileNum
        MsgBox "Notes exported to: " & filePath & vbCrLf & "Total slides processed: " & i - 1
    Else
        MsgBox "导出失败！" & vbCrLf & _
               "错误: " & Err.Description & vbCrLf & _
               "请运行 TestBasePath 检查路径设置。"
    End If
    On Error GoTo 0
End Sub

' ============================================================
' 函数2：导出备注为CSV格式
' ============================================================
Sub ExportNotesToCSV()
    Dim sld As Slide
    Dim notesText As String
    Dim i As Integer
    Dim fileNum As Integer
    Dim filePath As String
    Dim csvLine As String
    
    ' 初始化
    i = 1
    
    ' 直接使用全局常量
    filePath = BASE_PATH & "PPT_Notes.csv"
    fileNum = FreeFile()
    
    On Error Resume Next
    ' 打开文件并写入CSV表头
    Open filePath For Output As fileNum
    If Err.Number <> 0 Then
        MsgBox "无法创建文件！" & vbCrLf & _
               "错误: " & Err.Description & vbCrLf & _
               "请运行 TestBasePath 检查路径设置。"
        Exit Sub
    End If
    
    Print #fileNum, "SlideID,NotesContent"  ' CSV header
    
    ' 为每一张幻灯片创建条目
    For Each sld In ActivePresentation.Slides
        notesText = "(No Notes)"
        
        ' 检查是否有备注内容
        If sld.NotesPage.Shapes.Count > 1 Then
            On Error Resume Next
            notesText = sld.NotesPage.Shapes(2).TextFrame.TextRange.text
            If Err.Number <> 0 Or Trim(notesText) = "" Then
                notesText = "(No Notes)"
            End If
            On Error GoTo 0
        End If
        
        ' 处理备注内容中的特殊字符
        notesText = CleanText(notesText, "CSV")
        
        ' 构建CSV行
        csvLine = "Slide" & i & "," & Chr(34) & notesText & Chr(34)
        
        ' 写入文件
        Print #fileNum, csvLine
        
        i = i + 1
    Next sld
    
    Close fileNum
    On Error GoTo 0
    
    MsgBox "Notes exported to: " & filePath & vbCrLf & "Total slides processed: " & i - 1
End Sub

' ============================================================
' 通用函数：清理文本内容
' ============================================================
Function CleanText(text As String, Optional formatType As String = "TXT") As String
    If Trim(text) = "" Then
        CleanText = "(No Notes)"
        Exit Function
    End If
    
    Select Case formatType
        Case "CSV"
            ' CSV格式需要特殊处理
            CleanText = Replace(text, Chr(34), "'")  ' 替换双引号
            CleanText = Replace(CleanText, ",", "，")   ' 替换英文逗号
            CleanText = Replace(CleanText, vbCrLf, " | ")  ' 替换换行符
            CleanText = Replace(CleanText, vbCr, " | ")
            CleanText = Replace(CleanText, vbLf, " | ")
        Case Else
            ' TXT格式保持原样
            CleanText = text
    End Select
End Function

