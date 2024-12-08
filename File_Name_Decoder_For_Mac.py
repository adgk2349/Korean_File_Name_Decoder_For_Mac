import os
import shutil
import webbrowser
from urllib.parse import unquote
from tkinter import Tk, Label, Frame, Button, Entry, StringVar, filedialog, messagebox, Checkbutton, IntVar
from tkinterdnd2 import TkinterDnD, DND_FILES

previous_output_dir = None  # 이전 경로 저장

# Helper functions
def get_unique_filename(directory, filename):
    base, ext = os.path.splitext(filename)
    counter = 1
    unique_filename = filename
    while os.path.exists(os.path.join(directory, unique_filename)):
        unique_filename = f"{base}_copy{counter}{ext}"
        counter += 1
    return unique_filename

def clean_path(file_path):
    file_path = file_path.strip("{}")
    file_path = file_path.replace("\xa0", " ")
    return file_path


def is_file_downloaded(file_path):
    if not os.path.isfile(file_path):
        return False
    if file_path.endswith(".icloud"):
        return False
    try:
        os.stat(file_path)
        return True
    except OSError:
        return False

def decode_filenames(file_paths, output_dir, preserve_original):
    processed_files = set()
    skipped_files = []
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for file_path in file_paths:
        try:
            file_path = clean_path(file_path)
            if file_path in processed_files:
                continue
            processed_files.add(file_path)
            if not is_file_downloaded(file_path):
                skipped_files.append(file_path)
                print(f"스킵됨: {file_path} (다운로드가 되지 않았거나 파일이 없음.)")
                continue

            dir_name, file_name = os.path.split(file_path)
            decoded_name = unquote(file_name)
            if preserve_original:
                temp_copy_path = os.path.join(output_dir, get_unique_filename(output_dir, decoded_name))
                shutil.copy2(file_path, temp_copy_path)
                print(f"복사됨: {file_path} -> {temp_copy_path}")
            else:
                temp_copy_path = os.path.join(output_dir, decoded_name)
                if os.path.exists(temp_copy_path):
                    temp_copy_path = get_unique_filename(output_dir, decoded_name)
                os.rename(file_path, temp_copy_path)
                print(f"이동함: {file_path} -> {temp_copy_path}")
        except Exception as e:
            print(f"진행 실패: {file_path}")
            print(f"오류: {e}")
            messagebox.showerror("오류", f"진행 실패 {file_path}: {e}")

    processed_count = len(processed_files) - len(skipped_files)
    messagebox.showinfo(
        "진행 완료",
        f"{processed_count} 개의 파일(들)이 진행됨.\n깨진 파일 또는 다운로드되지 않은 아이클라우드 파일{len(skipped_files)} 개가 스킵됨."
    )

# GitHub 링크 열기 함수
def open_github():
    webbrowser.open("https://github.com/adgk2349/")

def create_gui():
    root = TkinterDnD.Tk()
    root.title("파일 이름 디코더 for MAC")
    root.geometry("600x400")
    root.minsize(600, 400)

    global output_dir_var, save_to_desktop_var, preserve_original_var, browse_button

    output_dir_var = StringVar(value=os.path.join(os.path.expanduser("~"), "Desktop"))
    save_to_desktop_var = IntVar(value=1)
    preserve_original_var = IntVar(value=1)

    # 상단 타이틀 프레임 (제목 + GitHub 링크)
    title_frame = Frame(root)
    title_frame.pack(fill="x", pady=5)

    # GitHub 링크
    github_label = Label(
        title_frame,
        text="@Made by 방구석_코드스미스",
        font=("Arial", 10),
        fg="grey",
        cursor="hand2"
    )
    github_label.pack(side="right", padx=10)

    # 마우스 이벤트로 색상 반전
    github_label.bind("<Enter>", lambda e: github_label.configure(fg="white"))  # 색상 반전
    github_label.bind("<Leave>", lambda e: github_label.configure(fg="grey"))  # 원래 상태로 복원

    # 클릭 이벤트로 GitHub 열기
    github_label.bind("<Button-1>", lambda e: open_github())

    # 출력 경로 선택 UI
    frame = Frame(root)
    frame.pack(pady=10, fill="x")

    Label(frame, text="저장 경로:").pack(side="left", padx=5)
    output_entry = Entry(frame, textvariable=output_dir_var, state="disabled")  # 비활성화
    output_entry.pack(side="left", fill="x", expand=True, padx=5)
    browse_button = Button(frame, text="찾기", state="disabled", command=lambda: open_output_dir_dialog(output_entry))  # 비활성화
    browse_button.pack(side="left", padx=5)

    # 옵션 설정
    options_frame = Frame(root)
    options_frame.pack(pady=10, fill="x")

    Checkbutton(
        options_frame,
        text="바탕화면에 저장",
        variable=save_to_desktop_var,
        command=lambda: toggle_save_to_desktop(output_entry, browse_button)
    ).pack(side="left", padx=5)

    Checkbutton(
        options_frame,
        text="기존 파일 유지",
        variable=preserve_original_var
    ).pack(side="left", padx=5)

    # 파일 선택 버튼 오른쪽 정렬
    file_button = Button(options_frame, text="파일 찾기", command=open_file_dialog)
    file_button.pack(side="right", padx=5)

    # 분리된 선 추가
    separator = Frame(root, height=2, bd=1, relief="sunken", bg="grey")
    separator.pack(fill="x", pady=10)

    # 드롭 영역
    drop_area = Label(root, text="파일 끌어다놓기", font=("Arial", 12))  # 배경색 제거
    drop_area.pack(fill="both", expand=True)
    drop_area.drop_target_register(DND_FILES)
    drop_area.dnd_bind("<<Drop>>", lambda event: on_drop(event, output_dir_var.get(), preserve_original_var.get()))

    root.mainloop()

def open_file_dialog():
    """파일 선택 대화 상자를 열어 여러 파일을 선택"""
    file_paths = filedialog.askopenfilenames(title="파일 선택")
    if file_paths:
        output_dir = output_dir_var.get()
        preserve_original = preserve_original_var.get()
        decode_filenames(file_paths, output_dir, preserve_original)

def open_output_dir_dialog(output_entry):
    global save_to_desktop_var, previous_output_dir, browse_button
    dir_path = filedialog.askdirectory(title="저장 경로 선택")
    if dir_path:
        output_entry.config(state="normal")
        output_entry.delete(0, "end")
        output_entry.insert(0, dir_path)
        output_dir_var.set(dir_path)
        desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
        if dir_path == desktop_path:
            save_to_desktop_var.set(1)
            output_entry.config(state="disabled")
            browse_button.config(state="disabled")
        else:
            save_to_desktop_var.set(0)
            output_entry.config(state="normal")
            browse_button.config(state="normal")
        previous_output_dir = dir_path

def toggle_save_to_desktop(output_entry, browse_button):
    global previous_output_dir
    if save_to_desktop_var.get() == 1:
        previous_output_dir = output_dir_var.get()
        desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
        output_dir_var.set(desktop_path)
        output_entry.config(state="disabled")
        browse_button.config(state="disabled")
    else:
        if previous_output_dir:
            output_dir_var.set(previous_output_dir)
        output_entry.config(state="normal")
        browse_button.config(state="normal")

def on_drop(event, output_dir, preserve_original):
    files = event.data.split()
    decode_filenames(files, output_dir, preserve_original)

if __name__ == "__main__":
    create_gui()