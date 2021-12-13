using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class LoadScean : MonoBehaviour
{
   public void NextScean(int scean)
    {
        SceneManager.LoadScene(scean);
    }
}
