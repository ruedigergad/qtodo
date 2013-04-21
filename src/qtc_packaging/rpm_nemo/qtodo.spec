# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.25
# 

Name:       qtodo

# >> macros
# << macros

Summary:    Q ToDo -- A Todo List Organizer
Version:    0.11.0
Release:    1
Group:      Applications/Productivity
License:    GPLv3
URL:        http://ruedigergad.github.com/qtodo
Source0:    %{name}_%{version}.tar.gz
Source100:  qtodo.yaml
Requires:   qmlcanvas
BuildRequires:  pkgconfig(QtCore) >= 4.7.0
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(qdeclarative-boostable)
BuildRequires:  pkgconfig(qmfclient)
BuildRequires:  desktop-file-utils

%description
Q ToDo is a simple todo list organizer. It supports nested todos. As one special feature it provides a quick and easy way for viewing the progress of sub-todos.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake 

make %{?jobs:-j%jobs}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
/opt/%{name}
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/icons/hicolor/*/apps/%{name}.svg
# >> files
# << files
